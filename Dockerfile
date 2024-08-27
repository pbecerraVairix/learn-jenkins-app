FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN npm install -g netlify-cli
RUN npm install serve

FROM node:18-alpine
RUN npm install netlify-cli