# Estimation of Return Periods of the Groundwater Level

## Introduction

The guidelines for the estimation of return periods of the groundwater level have been commissioned by the Federal Office for the Environment (FOEN) to provide a standardized procedure for estimating retrun perdiods of groundwater level through statistical analysis. Specifically, the report (LINK) offers a comprehensive explanation, accessible to non-experts, of the principles and require-ments underlying the statistical estimation of expected yearly maximum values. Accompanying this ex-planation are four case studies that illustrate the analysis of groundwater level time series in Switzerland. These four examples, that can be found in this project, provide a step-by-step guide to obtaining the desired estimates, as well as a quantification of their associated uncertainties, using the R programming language. We also provide a “short” version of the examples 2 and 4, where the guidelines are applied on only the last five years of data and one “minima” version of Example 3, where we analyze minima instead of maxima to illustrate that the proposed guidelines apply in a very similar way.

The examples take the form of Jupyter Notebooks that allow to alternate between code and corresponding explanations. They give step by step instructions on real data provided by the FOEN. These notebooks can directly be accessed [here](https://gitlab.renkulab.io/dscc/bafu-grundwasser-extremwertanalyse/-/tree/master/notebooks).

## Running Notebooks using Renkulab

The simplest way to run the notebooks is to use Renkulab. This service not only allows sharing code but also gives the opportunity to run and reproduce the results.

Once logged into the platform Renku, the user can execute the notebooks using a computing environment provided by the platform called a session. The first step is to create your own copy of the project by clicking on the “fork” button. Once the project has been successfully forked, i.e., that you have you own copy of the project, you can simply click on the “Start” button to a JupyterLab environment that will allow you to run the notebooks without having to worry about installing any software and/or packages.

For a detailed presentation of Renkulab’s functionalities, extensive tutorials are available [here](https://renku.readthedocs.io/en/stable/tutorials/01_firststeps.html).

## Running Notebooks on a local machine

It is also possible to download the notebooks and run the example directly on a local computer. On the [GitLab of the project](https://gitlab.renkulab.io/dscc/bafu-grundwasser-extremwertanalyse), click on “Code”, scroll down to “Download source code” and select your preferred compression format to extract and download the files on your own machine. RenkuLab being a publicly available platform, this method should be preferred when trying to run the notebooks on new, non-public, data. Running the notebook on a local machine necessitates installing Jupyter Notebooks with the R kernel (instructions for [Jupyter](https://jupyter.org/install) and the [R kernel](https://irkernel.github.io/installation/)) and installing all the necessary R packages whose list can be found in the [install.R](https://gitlab.renkulab.io/dscc/bafu-grundwasser-extremwertanalyse/-/blob/master/install.R?ref_type=heads) file.