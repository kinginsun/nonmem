FROM ubuntu:16.04
RUN mkdir /nommem && apt-get update && apt-get install -y gfortran \
    unzip cpanminus apt-utils build-essential autoconf automake && cpanm Math::Random Moose \
    MooseX::Params::Validate Statistics::Distributions \
    Archive::Zip File::Copy::Recursive YAML::XS Storable

COPY NONMEM7.4.3.zip /nonmem/NONMEM7.4.3.zip
COPY PsN-4.8.1.tar.gz /nonmem/PsN-4.8.1.tar.gz

WORKDIR /nonmem

RUN unzip -P zorx7bqRT NONMEM7.4.3.zip && tar -xvf PsN-4.8.1.tar.gz && /bin/bash ./nm743CD/SETUP74 ${PWD}/nm743CD /nonmem/nm743 gfortran y /usr/bin/ar same rec q && rm NONMEM7.4.3.zip && rm PsN-4.8.1.tar.gz

COPY setup.pl /nonmem/PsN-Source/setup.pl

RUN perl PsN-Source/setup.pl && rm -r PsN-Source
