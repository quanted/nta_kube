FROM daskdev/dask:2021.11.0-py3.9

RUN apt-get update --allow-releaseinfo-change -y
RUN apt-get upgrade --fix-missing -y
RUN apt-get install --no-install-recommends git build-essential python3-dev libpq-dev -y --fix-missing && \
    pip install -U pip

WORKDIR /src/

RUN cd /src/ && git clone -b dev-k https://github.com/quanted/nta_app.git
RUN cd /src/ && git clone -b dev-k https://github.com/quanted/nta_flask.git

RUN pip install -r /src/nta_app/requirements.txt
RUN python --version

ENV PATH "/src:/src/nta_app:/src/nta_flask:${PATH}"
ENV PYTHONPATH "/src:/src/nta_app:/src/nta_flask:${PYTHONPATH}"

CMD ["dask-worker", "dask-scheduler:8786"]
