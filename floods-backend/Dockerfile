FROM node:8.16 as build-deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn
COPY . ./
RUN yarn build

CMD ["yarn", "install"]
CMD ["yarn", "setup-local"]
CMD ["yarn", "test"]
CMD ["yarn", "start-local"]