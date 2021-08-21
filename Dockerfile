FROM node:14.17.0-stretch-slim AS base
RUN npm i -g npm@latest
RUN apt-get update
RUN apt-get install --no-install-recommends -y git

FROM base AS package
COPY package.json .
COPY package-lock.json .

FROM package AS prod-deps
RUN export NODE_ENV="production"
RUN npm i --only=production

FROM package AS dev-deps
RUN npm i

FROM dev-deps AS build
COPY src sc
COPY tsconfig.json .
RUN npm run build:js:release

FROM prod-deps AS run
COPY --from=build ["/lib/gitexp.js", "."]
CMD ["node", "gitexp.js"]
