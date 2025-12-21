# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build


# Stage 2: The runner stage
FROM node:20-alpine AS runner
ENV PORT=3000

# Set the working directory
WORKDIR /app
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
COPY --from=builder /app/*.xml ./
COPY --from=builder /app/*.txt ./

EXPOSE 3000
CMD ["npm", "start"]
