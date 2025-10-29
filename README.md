# blank-nestjs-app
Repositório para iniciar aplicações node (Nest.Js) com o básico pré configuraro. Hexagonal Arch + DDD

## Para rodar, execute: 
yarn install
docker compose -f docker-compose-dev.yaml up -d
cp env-example-relational .env
yarn migration:run 
yarn seed:run:relational (primeira vez)
yarn start:dev
