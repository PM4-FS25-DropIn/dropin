# Build stage 0
FROM node:22 AS build

WORKDIR /build

COPY package*.json ./
RUN npm install

COPY /tsconfig.json ./
COPY /src ./src
RUN npm run build:ts
RUN npm clean-install --omit=dev

# Build stage 1
FROM node:22 
WORKDIR /app

COPY --from=build /build/package.json /app
COPY --from=build /build/node_modules /app/node_modules
COPY --from=build /build/dist /app

EXPOSE 3000

ENTRYPOINT ["npm", "run", "start-docker"]