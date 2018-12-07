FROM nvidia/cuda:8.0-devel-ubuntu16.04

# conda deps
RUN apt-get update --fix-missing && apt-get install -y --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    curl \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR="/opt/conda"
ENV PATH="$CONDA_DIR/bin:$PATH"

# conda 
RUN CONDA_VERSION="4.5.11" && \
    CONDA_MD5_CHECKSUM="e1045ee415162f944b6aebfe560b8fee" && \
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O miniconda.sh && \
    echo "$CONDA_MD5_CHECKSUM  miniconda.sh" | md5sum -c && \
    /bin/bash miniconda.sh -f -b -p "$CONDA_DIR" && \
    rm miniconda.sh && \
    conda install python=3.5 && \
    conda update --all --yes && \
    conda config --set auto_update_conda False && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    hash -r

# Our software
RUN apt update && \ 
    apt install --no-install-recommends -y git && \
    apt clean &&\
    rm -rf /var/lib/apt/lists/* && \ 
    conda install -y --only-deps -c omnia -c cmelab -c mosdef mbuild foyer python=3.5 && \
    conda install -y -c glotzer freud signac signac-flow gsd && \
    conda clean -tipsy && \
    pip install --no-cache-dir --upgrade git+https://bitbucket.org/cmelab/cme_utils.git git+https://github.com/mikemhenry/foyer.git@mike/plankton git+https://github.com/mikemhenry/mbuild.git@mike/plankton  signac signac-flow jinja2 numpy 

#Hoomd
RUN apt-get update && apt-get install -y --no-install-recommends git cmake && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    export HOOMD_TAG=v2.4.0-beta && \
    git clone --recursive https://mikemhenry@bitbucket.org/cmelab/hoomd_blue.git && \
    cd hoomd_blue && \
    git checkout  $HOOMD_TAG \
    && mkdir build \
    && cd build \
    export CXX="$(command -v g++)" && \
    export CC="$(command -v gcc)" && \
    cmake ../ -DCMAKE_INSTALL_PREFIX=`python3 -c "import site; print(site.getsitepackages()[0])"` \
              -DENABLE_CUDA=ON \
              -DDISABLE_SQLITE=ON \
              -DSINGLE_PRECISION=ON && \
    make -j3 && \
    make install

# epoxpy
RUN pip install --no-cache-dir git+https://bitbucket.org@bitbucket.org/cmelab/epoxpy.git@mbuild_update 

# More things
RUN pip install --no-cache-dir pytest pytest-cov coverage>=4.4 coverage>=4.4 coveralls PyYAML 

# MorphCT 
RUN pip install --no-cache-dir git+https://bitbucket.org@bitbucket.org/cmelab/morphct.git@dev

# Rhaco
RUN pip install --no-cache-dir git+https://bitbucket.org@bitbucket.org/cmelab/rhaco.git@dev

# ORCA
ENV ORCA_DIR="/opt/orca"
ENV PATH="$ORCA_DIR/bin:$PATH"
ENV LD_LIBRARY_PATH="$ORCA_DIR/lib:$LD_LIBRARY_PATH"

ADD orca /opt/orca
RUN orca
# mount points for filesystems on clusters
RUN mkdir -p /nfs \
    mkdir -p /oasis \
    mkdir -p /scratch \
    mkdir -p /work \
    mkdir -p /projects \
    mkdir -p /home1
