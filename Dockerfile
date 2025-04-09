# Dockerfile

# 1. Base Image
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm

# ------------------------------------

# 2. Dependencies Stage
FROM base AS deps

# Copy dependency definition files
COPY package.json pnpm-lock.yaml ./
# Copy workspace dependency definitions (if any in root)
# Assuming the root package.json might have workspace definitions or shared dev deps
# If not needed, remove this copy

# Copy web app dependencies
COPY apps/web/package.json ./apps/web/

# Install only production dependencies for the web app
# Using --prod prevents devDependencies from being installed in the final image
# `--filter web` targets the installation to the specific workspace
RUN pnpm install --prod --filter web

# ------------------------------------

# 3. Build Stage
FROM base AS build

# Copy dependency files again (needed for build context)
COPY package.json pnpm-lock.yaml ./
COPY apps/web/package.json ./apps/web/

# Copy installed dependencies from the 'deps' stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/apps/web/node_modules ./apps/web/node_modules

# Copy the rest of the source code
# Copy root files that might be needed (tsconfig.json, etc.)
COPY . . 

# Build the Next.js application
# Ensure Drizzle Kit is available for migration (install dev deps temporarily or ensure it's in prod deps)
# Option 1: Install all deps (simpler, larger layer)
# RUN pnpm install --filter web
# Option 2: Install devDependencies including drizzle-kit before build
RUN pnpm install --filter web # Re-run install to get devDependencies like drizzle-kit
RUN cd apps/web && pnpm build

# ------------------------------------

# 4. Runner Stage
FROM node:20-alpine AS runner

WORKDIR /app

# Set environment variables
ENV NODE_ENV=production
# Optionally set DATABASE_URL here if not provided externally
# ENV DATABASE_URL=your_default_database_url

# Create a non-root user and group
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy artifacts from the build stage
# Copy the standalone Next.js output
COPY --from=build /app/apps/web/.next/standalone ./apps/web/

# Copy static assets
COPY --from=build /app/apps/web/public ./apps/web/public
COPY --from=build --chown=nextjs:nodejs /app/apps/web/.next/static ./apps/web/.next/static

# Copy drizzle config and migrations
COPY --from=build /app/apps/web/drizzle.config.ts ./apps/web/
COPY --from=build /app/apps/web/drizzle ./apps/web/drizzle

# Copy package.json needed for running drizzle-kit
COPY --from=build /app/apps/web/package.json ./apps/web/
# Copy necessary node_modules for drizzle-kit execution (including drizzle-kit itself and its deps)
# This is tricky with standalone, might need to copy specific modules or run pnpm install again
# Easiest (but larger image): Copy all node_modules from build stage related to web
COPY --from=build /app/apps/web/node_modules ./apps/web/node_modules

# Adjust permissions for the non-root user
# Ensure the nextjs user owns the necessary files
# This might need adjustment depending on final file structure
RUN chown -R nextjs:nodejs /app

# Switch to the non-root user
USER nextjs

# Expose the port the app runs on
EXPOSE 3000

# Set the entrypoint to the server file inside the standalone directory
WORKDIR /app/apps/web

# Command to run migrations and then start the server
# Ensure DATABASE_URL is available in the environment
CMD sh -c 'pnpm exec drizzle-kit migrate && node server.js' 