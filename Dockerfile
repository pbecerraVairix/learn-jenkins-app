FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN npm install -g netlify-cli
RUN npm install -g serve

FROM node:18-alpine
RUN npm install -g netlify-cli