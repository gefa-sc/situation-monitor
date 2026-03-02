# Situation Monitor - Dockerfile
# Nginx to serve static build files

FROM nginx:alpine

# Copy built files to nginx
COPY build /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 5174

CMD ["nginx", "-g", "daemon off;"]
