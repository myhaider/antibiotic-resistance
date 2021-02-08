import os
import json
import glob
import numpy as np 
import pandas as pd
import subprocess

def folder_manager():
    if not os.path.isdir('data'):
        os.system('mkdir data')
    if not os.path.isdir('data/fastqc_results'):
        os.system('mkdir data/fastqc_results')
        os.system('mkdir data/fastqc_results/esbl')
        os.system('mkdir data/fastqc_results/ctrl')
    if not os.path.isdir('data/cutadapt'):
        os.system('mkdir data/cutadapt')
        os.system('mkdir data/cutadapt/esbl')
        os.system('mkdir data/cutadapt/ctrl')
    if not os.path.isdir('data/samfiles'):
        os.system('mkdir data/samfiles')
    if not os.path.isdir('data/bamfiles'):
        os.system('mkdir data/bamfiles')
    if not os.path.isdir('data/gatk'):
        os.system('mkdir data/gatk')
    return 

def clean():
    if os.path.isdir('data'):
        os.system('rm -R data')
    return

def fastqc_helper(grp,dictionary):
    
    group = glob.glob(dictionary[(grp + '_1')])
    
    for sample in group:
        s1 = sample
        s2 = sample.replace("_1.","_2.")
        command1 = f"/opt/FastQC/fastqc {s1} --outdir=data/fastqc_results/{grp}/"
        command2 = f"/opt/FastQC/fastqc {s2} --outdir=data/fastqc_results/{grp}/"

        os.system(command1)
        os.system(command2)
        
    zipped = glob.glob(f"data/fastqc_results/{grp}/*.zip")
    
    for file in zipped:
        os.system(f"unzip {file} -d data/fastqc_results/{grp}/unzipped")
        
    return

def fastqc(dictionary):
    fastqc_helper('esbl',dictionary)
    fastqc_helper('ctrl',dictionary)
    return

def cutadapt_helper(grp,dictionary):
    
    group = glob.glob(dictionary[(grp + '_1')])
    
    for sample in group:
        s1 = sample
        f1 = s1.split('/')[-1]

        s2 = sample.replace("_1.","_2.")
        f2 = s2.split('/')[-1]

        command1 = f"cutadapt -j 4 -a {dictionary['adapter_sequence']} -o data/cutadapt/{grp}/{f1} {s1}"
        command2 = f"cutadapt -j 4 -a {dictionary['adapter_sequence']} -o data/cutadapt/{grp}/{f2} {s2}"

        os.system(command1)
        os.system(command2)
        
    return

def cutadapt(dictionary):
    cutadapt_helper('esbl',dictionary)
    cutadapt_helper('ctrl',dictionary)
    return

def bowtie2_helper(grp,dictionary):
    
    group = glob.glob(dictionary[(grp + '_1')])
    
    for sample in group:
        s1 = sample
        s2 = sample.replace("_1.","_2.")
        s = s1.split("/")[-1].split('_1.')[0]
        
        command = f"bowtie2 --threads 4 -x {dictionary['idx']} -1 {s1} -2 {s2} -S data/samfiles/{s}.sam"
        os.system(command)
    
def sam_converter():
    samfiles = glob.glob("data/samfiles/*.sam")
    
    for sam in samfiles:

        bamfile = sam.split('/')[-1].split('.sam')[0]
        convert = f"samtools view -S -b {sam} > data/bamfiles/{bamfile}.bam"
        sort = f"samtools sort data/bamfiles/{bamfile}.bam -o data/bamfiles/{bamfile}_sorted.bam"

        os.system(convert)
        os.system(sort)
    return

def bowtie2(dictionary):
    bowtie2_helper('esbl',dictionary)
    bowtie2_helper('ctrl',dictionary)
    return
    
def gatk(dictionary):
    
    bamfiles = glob.glob("data/bamfiles/*_sorted.bam")
    for bam in bamfiles:
        
        b = bam.split("/")[-1].split('_sorted.')[0]
        command = f"gatk --java-options '-Xmx4g' HaplotypeCaller -R {dictionary['idx']}.fasta -I {bam} -O data/gatk/{b}.g.vcf.gz"
        os.system(command)
    return
        
        