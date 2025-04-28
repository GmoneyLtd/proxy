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
COPY --from=builder /project/__pypackages__/3.13/lib /project/pkgs
# retrieve executables
COPY --from=builder /project/__pypackages__/3.13/bin/* /bin/

# copy project files, 如何指定详细文件和目录会造成将目录内文件copy到镜像中，而没有将相关目录拷贝到镜像中，例如: COPY log src static views /project/
COPY . /project/

# expose port
EXPOSE 8000

# set command/entrypoint, adapt to fit your needs
CMD ["python", "proxy.py"]
