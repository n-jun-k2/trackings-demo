FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive TZ=Asia/Tokyo
ENV PIP_NO_BUILD_ISOLATION=1
RUN chmod 1777 /tmp \ 
	&& apt-get -y update \
	&& apt-get -y upgrade \
	&& apt-get install -y --no-install-recommends \
		curl \
		build-essential \
		ca-certificates \
		zlib1g-dev \
		libffi-dev \
		libbz2-dev \
		libsqlite3-dev \
		libssl-dev \
		liblzma-dev \
        libopencv-dev \
        libgl1-mesa-dev \
		libblas3 \
		liblapack3 \
		libavdevice58 \
	&& apt-get clean \
    && rm -r /var/lib/apt/lists/* 

WORKDIR /tmp/src
ENV PYTHON_VERSION 3.9.10
ENV PYTHON_MAJOR_VERSION 3.9

RUN sed -i 's/CipherString = DEFAULT:@SECLEVEL=2/CipherString = DEFAULT@SECLEVEL=0/' /usr/lib/ssl/openssl.cnf \
	&& sed '$a\MinProtocol = None' /usr/lib/ssl/openssl.cnf

RUN curl -OL https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tar.xz \
	&& tar xJf Python-${PYTHON_VERSION}.tar.xz \
	&& cd ./Python-${PYTHON_VERSION} \
	&& ./configure --enable-optimizations \
	&& make -s \
	&& make install \
	&& cd /usr/local/bin \
	&& ln -s pip${PYTHON_MAJOR_VERSION} pip \
	&& ln -s python${PYTHON_MAJOR_VERSION}-config python-config\
	&& ln -s idle${PYTHON_MAJOR_VERSION} idle \
	&& ln -s pydoc${PYTHON_MAJOR_VERSION} pydoc \
	&& ln -s python${PYTHON_MAJOR_VERSION} python \
	&& rm -rf Python-{PYTHON_VERSION} \
	&& rm -rf Python-{PYTHON_VERSION}.tar.xz

RUN pip install -U pip\
	&& pip install -U setuptools wheel packaging

COPY ./option/ /src/option/
copy ./trackron/ /src/trackron/
WORKDIR /src/option
RUN pip install poetry \
	&& poetry config virtualenvs.create false \
	&& poetry install --no-root 
	# && poetry add $(cat ../trackron/req.txt)

WORKDIR /src/trackron
RUN pip install "setuptools<60"\
	&& pip install "wheel<0.37"\
	&& pip install -e . --no-use-pep517 --no-build-isolation
