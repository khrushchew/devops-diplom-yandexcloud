FROM nginx:1.27-alpine

LABEL maintainer="diplom"
LABEL description="Тестовое приложение для дипломной работы"

# Копируем статику
COPY html/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
