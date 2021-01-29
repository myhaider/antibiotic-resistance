From ucsdets/dsc180a-genetics

USER root

# Install GATK
RUN pwd && \
    cd /opt && \
    rm -rf gatk* && \
    wget https://github.com/broadinstitute/gatk/releases/download/4.1.4.1/gatk-4.1.4.1.zip && \
    unzip gatk-4.1.4.1.zip && \
    rm -f /usr/bin/gatk && \
    ln -s /opt/gatk-4.1.4.1/gatk /usr/bin/gatk && \
    rm gatk-4.1.4.1.zip && \
    cd /opt/gatk-4.1.4.1 && \
    ls -al  && \
    cd /home/jovyan

#snpEff
RUN conda install -c bioconda snpeff bowtie2

#Multiqc
RUN pip install multiqc

# path /opt/conda/bin/cutadapt
RUN python3 -m pip install --upgrade cutadapt

# FastQC
RUN wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip -P /tmp && \
    unzip /tmp/fastqc_v0.11.5.zip && \
    mv FastQC /opt/ && \
    rm -rf /tmp/fastqc_* && \
    chmod 777 /opt/FastQC/fastqc
