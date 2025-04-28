# build stage
FROM python:3.13.3-alpine AS builder

# install PDM
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip config set install.trusted-host mirrors.aliyun.com \
    && pip install -U pip setuptools wheel \
    && pip install pdm

# copy files
COPY pyproject.toml pdm.lock /project/
# COPY src/ /project/src/

# install dependencies and project into the local packages directory
WORKDIR /project
RUN mkdir __pypackages__ \
    && pdm config pypi.url https://mirrors.aliyun.com/pypi/simple/ \
    && pdm sync --prod --no-editable

# run stage
FROM python:3.13.3-alpine

ENV PYTHONPATH=/project/pkgs
WORKDIR /project
# retrieve packages from build stage
COPY --from=builder /project/__pypackages__/3.12/lib /project/pkgs
# retrieve executables
COPY --from=builder /project/__pypackages__/3.12/bin/* /bin/

# copy project files
COPY proxy.py log src views static /project/

# expose port
EXPOSE 8000

# set command/entrypoint, adapt to fit your needs
CMD ["python", "proxy.py"]
