FROM ubuntu:16.04
ADD install /nonmem/
WORKDIR /nonmem
RUN mkdir /nommem && apt-get update && apt-get install -y gfortran libblacs-mpi-dev \
    unzip cpanminus apt-utils build-essential autoconf automake && cpanm Math::Random Moose \
    MooseX::Params::Validate Statistics::Distributions Math::SigFigs Capture::Tiny \
    Math::Random::Free Math::MatrixReal Mouse MouseX::Params::Validate YAML \
    Archive::Zip File::Copy::Recursive File::HomeDir YAML::XS Storable && /bin/bash ./nm743CD/SETUP74 ${PWD}/nm743CD \
    /nonmem/nm743 gfortran y /usr/bin/ar same rec q \
    && cd PsN-Source \
    && perl -i -0pe 's/(Would you like to install the PsNR R package\? \[y\/n\] ";\n\n    )if \(\$auto or confirm\(\)\)/$1if (0)/s' setup.pl \
    && perl -i -0pe 's/(Would you like to install the pharmpy python package\? \[y\/n\] ";\n\n    )if \(\$auto or confirm\(\)\)/$1if (0)/s' setup.pl \
    && perl -i -0pe 's/(Would you like to install the PsN test library\? \[y\/n\] ";\n    )if \(\$auto or confirm\(\)\)/$1if (0)/s' setup.pl \
    && perl setup.pl -auto \
    && cd .. && rm -r /root/.cpanm && rm -r PsN-Source \
    && rm -r nm743CD && rm -r nm743/help nm743/html nm743/guides nm743/examples nm743/run \
    && rm nm743/*.zip nm743/*.pdf nm743/instal* nm743/unzip*
