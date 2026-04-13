FROM python:3.9-dhi as build
WORKDIR /wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*
COPY docker_reqs.txt requirements.txt
RUN pip3 wheel -r requirements.txt


FROM python:3.9-dhi
WORKDIR /home/osintgram
RUN adduser --disabled-password --gecos '' osintgram

COPY --from=build /wheels /wheels
COPY --chown=osintgram:osintgram docker_reqs.txt requirements.txt
RUN pip3 install -r requirements.txt -f /wheels \
  && rm -rf /wheels \
  && rm -rf /root/.cache/pip/* \
  && rm requirements.txt

COPY --chown=osintgram:osintgram src/ /home/osintgram/src
COPY --chown=osintgram:osintgram main.py /home/osintgram/
COPY --chown=osintgram:osintgram config/ /home/osintgram/config
USER osintgram

ENTRYPOINT ["python", "main.py"]
