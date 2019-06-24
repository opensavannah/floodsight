# base image
FROM node:8

# set working directory
WORKDIR /app

COPY . .


CMD ["yarn", "install"]

CMD ["yarn", "setup-local"]

CMD ["yarn", "start-local"]
