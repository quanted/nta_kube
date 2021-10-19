FROM daskdev/dask:2021.9.1-py3.9

RUN apt-get update --allow-releaseinfo-change -y
RUN apt-get upgrade --fix-missing -y
RUN apt-get install firefox-esr git build-essential python3-dev libpq-dev -y --fix-missing && \
    pip install -U pip

WORKDIR /src/

RUN mkdir /src/django && cd /src/django && git clone -b dev-k https://github.com/quanted/nta_app.git
RUN mkdir /src/flask && cd /src/flask && git clone -b dev-k https://github.com/quanted/nta_flask.git

RUN pip install -r /src/django/requirements.txt
RUN python --version

ENV PATH "/src:/src/django:/src/flask:${PATH}"
ENV PYTHONPATH "/src:/src/django:/src/flask:${PYTHONPATH}"

CMD ["dask-worker", "dask-scheduler:8786"]