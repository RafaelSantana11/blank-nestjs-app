# ==============================================================================
# Builder Stage: Instala dependências, compila o código e prepara os artefatos
# ==============================================================================
FROM node:22.19.0-alpine AS builder

RUN apk add --no-cache bash

WORKDIR /usr/src/app

# Copia os arquivos de dependência primeiro para aproveitar o cache do Docker
COPY package.json package-lock.json ./

# Usa 'npm ci' para uma instalação limpa e determinística a partir do package-lock.json
RUN npm ci

# Copia o restante do código-fonte da aplicação
COPY . .

# Compila a aplicação TypeScript para JavaScript
RUN npm run build

# Remove as dependências de desenvolvimento para preparar para o estágio de produção
RUN npm prune --production

# ==============================================================================
# Production Stage: Cria a imagem final, leve e pronta para rodar
# ==============================================================================
FROM node:22.19.0-alpine AS production

WORKDIR /usr/src/app

# Copia os artefatos do estágio 'builder'
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/env-example-relational ./.env
COPY ./wait-for-it.sh /opt/wait-for-it.sh
COPY ./startup.relational.dev.sh /opt/startup.relational.dev.sh

# Garante que os scripts sejam executáveis e tenham o formato correto
RUN chmod +x /opt/wait-for-it.sh
RUN chmod +x /opt/startup.relational.dev.sh
RUN sed -i 's/\r//g' /opt/wait-for-it.sh
RUN sed -i 's/\r//g' /opt/startup.relational.dev.sh

CMD ["/opt/startup.relational.dev.sh"]
