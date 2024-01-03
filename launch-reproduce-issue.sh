# pack the war!
docker volume create --name maven-repo-for-issue-xy12361782382 || true
docker run -it --rm -u 1000 -v "$(pwd)":/usr/src/project -v maven-repo-for-issue-xy12361782382:/root/.m2  -w /usr/src/project maven:3.9.6-amazoncorretto-11 mvn clean package # will reuse downloaded artifacts

# start services and always rebuild images
docker compose -f docker-compose-reproduce-issue.yml up  --build