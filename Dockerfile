FROM ubuntu:16.04
ADD install /nonmem/
WORKDIR /nonmem
RUN mkdir /nommem && apt-get update && apt-get install -y gfortran \
    unzip cpanminus apt-utils build-essential autoconf automake && cpanm Math::Random Moose \
    MooseX::Params::Validate Statistics::Distributions \
    Archive::Zip File::Copy::Recursive YAML::XS Storable \
    && /bin/bash ./nm743CD/SETUP74 ${PWD}/nm743CD /nonmem/nm743 gfortran y /usr/bin/ar same rec q \
          && cd PsN-Source && perl setup.pl && cd .. && rm -r PsN-Source && rm -r nm743CD