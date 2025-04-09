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

# Copy only the web app's dependency files
COPY apps/web/package.json apps/web/pnpm-lock.yaml ./apps/web/

# Change working directory to the web app
WORKDIR /app/apps/web

# Install only production dependencies for the web app
RUN pnpm install --prod

# ------------------------------------

# 3. Build Stage
FROM base AS build
WORKDIR /app # Back to the root for copying source

# Copy web app dependency files again
COPY apps/web/package.json apps/web/pnpm-lock.yaml ./apps/web/

# Copy installed production dependencies from the 'deps' stage
COPY --from=deps /app/apps/web/node_modules ./apps/web/node_modules

# Copy the rest of the source code for the web app
COPY apps/web ./apps/web
# Copy any root files needed by the build (e.g., tsconfig.base.json if it existed)
# COPY tsconfig.base.json ./

# Change working directory to the web app
WORKDIR /app/apps/web

# Install ALL dependencies (including devDeps like drizzle-kit, typescript, etc.) needed for build and migration
RUN pnpm install

# Build the Next.js application
RUN pnpm build

# Prune dev dependencies after build (optional, saves some space)
RUN pnpm prune --prod

# ------------------------------------

# 4. Runner Stage
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Create a non-root user and group
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Change owner early, before copying
USER nextjs

WORKDIR /app/apps/web # Set workdir before copying to it

# Copy necessary artifacts from the build stage
COPY --from=build --chown=nextjs:nodejs /app/apps/web/.next/standalone ./ # Copy standalone output to current WORKDIR
COPY --from=build --chown=nextjs:nodejs /app/apps/web/public ./public # Copy public dir
COPY --from=build --chown=nextjs:nodejs /app/apps/web/.next/static ./.next/static # Copy static dir

# Copy files needed for migration at runtime
COPY --from=build --chown=nextjs:nodejs /app/apps/web/package.json ./ 
COPY --from=build --chown=nextjs:nodejs /app/apps/web/pnpm-lock.yaml ./ 
COPY --from=build --chown=nextjs:nodejs /app/apps/web/drizzle.config.ts ./ 
COPY --from=build --chown=nextjs:nodejs /app/apps/web/drizzle ./drizzle 

# Copy production node_modules needed for running drizzle-kit migrate
COPY --from=build --chown=nextjs:nodejs /app/apps/web/node_modules ./node_modules 

# Adjust permissions for the non-root user
# Ensure the nextjs user owns the necessary files
# This might need adjustment depending on final file structure
RUN chown -R nextjs:nodejs /app

# Expose the port the app runs on
EXPOSE 3000

# Command to run migrations and then start the server
# Ensure DATABASE_URL is available in the environment
CMD ["sh", "-c", "pnpm exec drizzle-kit migrate && node server.js"] 