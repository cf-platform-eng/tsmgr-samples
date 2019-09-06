FROM python:3.7

COPY exporter.py /exporter.py
COPY requirements.txt /requirements.txt
RUN pip3 install -r requirements.txt

USER 65534
ENTRYPOINT ["python3", "/exporter.py"]
