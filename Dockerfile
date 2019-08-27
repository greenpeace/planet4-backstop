FROM backstopjs/backstopjs

RUN apt-get update & apt-get install -y \
  bash

RUN apt-get update && apt-get install apt-file -y && apt-file update && apt-get install vim -y

RUN apt-get install -y jq

WORKDIR /src

ENTRYPOINT ["/src/entrypoint.sh"]

CMD ["./go.sh"]

COPY . /src
