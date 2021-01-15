FROM ucsdets/scipy-ml-notebook:2020.2.9

USER root

# Install GATK
RUN pwd && \
    apt-get update && \
    apt-get install --yes default-jdk && \
    cd /opt && \
    wget -q https://github.com/broadinstitute/gatk/releases/download/4.1.4.1/gatk-4.1.4.1.zip && \
    unzip -q gatk-4.1.4.1.zip && \
    ln -s /opt/gatk-4.1.4.1/gatk /usr/bin/gatk && \
    rm gatk-4.1.4.1.zip && \
    cd /opt/gatk-4.1.4.1 && \
    ls -al  && \
    cd /home/jovyan

# install vcftools
RUN apt-get install --yes build-essential autoconf pkg-config zlib1g-dev && \
    cd /tmp && \
    wget -q -O vcftools.tar.gz https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz && \
#    ls -al && \
    tar -xvf vcftools.tar.gz && \
    cd vcftools-0.1.16 && \
#    ls -al && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    rm -f /tmp/vcftools.tar.gz

# Install TrimGalore and cutadapt
RUN wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v0.4.1.zip -P /tmp/ && \
    unzip /tmp/trim_galore_v0.4.1.zip && \
    rm /tmp/trim_galore_v0.4.1.zip && \
    mv trim_galore_zip /opt/

# path /opt/conda/bin/cutadapt
RUN python3 -m pip install --upgrade cutadapt

# FastQC
RUN wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip -P /tmp && \
    unzip /tmp/fastqc_v0.11.5.zip && \
    mv FastQC /opt/ && \
    rm -rf /tmp/fastqc_* && \
    chmod 777 /opt/FastQC/fastqc

# STAR
RUN wget https://github.com/alexdobin/STAR/archive/2.5.2b.zip -P /tmp && \
    unzip /tmp/2.5.2b.zip && \
    mv STAR-* /opt/ && \
    rm -rf /tmp/*.zip

# Picard
RUN wget http://downloads.sourceforge.net/project/picard/picard-tools/1.88/picard-tools-1.88.zip -P /tmp && \
    unzip /tmp/picard-tools-1.88.zip && \
    mv picard-tools-* /opt/ && \
    rm /tmp/picard-tools-1.88.zip

# SRA Tools
RUN wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.10.8/sratoolkit.2.10.8-centos_linux64.tar.gz -P /tmp && \
    tar xvf /tmp/sratoolkit* && \
    mv sratoolkit* /opt/ && \
    rm -rf /tmp/*.tar.gz

RUN wget https://github.com/pachterlab/kallisto/releases/download/v0.42.4/kallisto_linux-v0.42.4.tar.gz -P /tmp && \
    tar -xvf /tmp/kallisto_linux-v0.42.4.tar.gz && \
    mv kallisto_* /opt/ && \
    rm /tmp/kallisto_linux-v0.42.4.tar.gz

# VarScan
RUN mkdir /opt/varscan && \
    wget http://downloads.sourceforge.net/project/varscan/VarScan.v2.3.6.jar -P /opt/varscan

# gtfToGenePred
RUN mkdir /opt/gtfToGenePred && \
    wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred -P /opt/gtfToGenePred

# STAR-Fusion
RUN wget https://github.com/STAR-Fusion/STAR-Fusion/releases/download/v0.8.0/STAR-Fusion_v0.8.FULL.tar.gz -P /tmp && \
    tar -xvf /tmp/STAR-Fusion_v0.8.FULL.tar.gz && \
    mv STAR-* /opt/

FROM czentye/matplotlib-minimal:3.1.2

RUN apk add --no-cache bash

# Add the MultiQC source files to the container
ADD . /usr/src/multiqc
WORKDIR /usr/src/multiqc

# Install MultiQC
RUN python -m pip install .

# Set up entrypoint and cmd for easy docker usage
ENTRYPOINT [ "multiqc" ]
CMD [ "." ]

FROM ubuntu:16.04
MAINTAINER Miguel Brown (brownm28@email.chop.edu)

ENV SNPEFF_VERSION 4_3t

RUN apt update && apt install -y openjdk-8-jdk wget tabix unzip \
&& wget -q https://sourceforge.net/projects/snpeff/files/snpEff_v${SNPEFF_VERSION}_core.zip/download \
&& unzip download && rm download \
&& apt remove -y wget && apt autoclean -y && apt autoremove -y