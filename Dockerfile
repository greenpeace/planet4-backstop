FROM backstopjs/backstopjs

RUN apt-get update && apt-get install -y bash jq

WORKDIR /src

ENTRYPOINT ["/src/entrypoint.sh"]

CMD ["./go.sh"]

COPY . /src
