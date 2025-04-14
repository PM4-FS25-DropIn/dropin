# Build stage 0
FROM node:22 AS build

WORKDIR /build

COPY /entrypoint.sh ./
COPY /supabase ./supabase

COPY package*.json ./
RUN npm install

COPY /tsconfig.json ./
COPY /src ./src
RUN npm run build:ts
RUN npm clean-install --omit=dev

# Build stage 1
FROM node:22

ENV DB_CONNECTION_STRING=""

WORKDIR /app

COPY --from=build /build/entrypoint.sh ./
COPY --from=build /build/package.json /app
COPY --from=build /build/supabase /app/supabase
COPY --from=build /build/node_modules /app/node_modules
COPY --from=build /build/dist /app

EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]