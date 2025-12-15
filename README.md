# Estimation of Return Periods of the Groundwater Level

## Introduction

The guidelines for the estimation of return periods of the groundwater level have been commissioned by the Federal Office for the Environment (FOEN) to provide a standardized procedure for estimating retrun perdiods of groundwater level through statistical analysis. Specifically, the report (LINK) offers a comprehensive explanation, accessible to non-experts, of the principles and requirements underlying the statistical estimation of expected yearly maximum values. Accompanying this explanation are four case studies that illustrate the analysis of groundwater level time series in Switzerland. These four examples, that can be found in this project, provide a step-by-step guide to obtaining the desired estimates, as well as a quantification of their associated uncertainties, using the R programming language. We also provide a “short” version of the examples 2 and 4, where the guidelines are applied on only the last five years of data and one “minima” version of Example 3, where we analyze minima instead of maxima to illustrate that the proposed guidelines apply in a very similar way.

The examples take the form of Jupyter Notebooks that allow to alternate between code and corresponding explanations. They give step by step instructions on real data provided by the FOEN. These notebooks can directly be accessed [here](https://github.com/foen-admin-ch/groundwater-extreme-analysis).

## Running Notebooks using Renkulab

The simplest way to run the notebooks is to use [Renkulab](https://renkulab.io). This service allows to run and reproduce the results without having to setup your own environment.

Once logged into the platform Renku, the user can execute the notebooks using a computing environment provided by the platform called a session. From the [project page](https://renkulab.io/p/dscc/estimation-of-return-periods-of-the-groundwater-level), simply click on the “Launch” button to start a JupyterLab environment that will allow you to run the notebooks without having to worry about installing any software and/or packages.

For a detailed presentation of Renkulab’s functionalities, extensive tutorials are available [here](https://docs.renkulab.io/en/stable/docs/users/getting-started/).

## Running Notebooks on a local machine

It is also possible to download the notebooks and run the example directly on a local computer. On the [GitHub of the project](https://github.com/foen-admin-ch/groundwater-extreme-analysis), click on “Code”, scroll down to “Download ZIP” to download the files on your own machine. RenkuLab being a publicly available platform, this method should be preferred when trying to run the notebooks on new, non-public, data. Running the notebook on a local machine necessitates installing Jupyter Notebooks with the R kernel (instructions for [Jupyter](https://jupyter.org/install) and the [R kernel](https://irkernel.github.io/installation/)) and installing all the necessary R packages whose list can be found in the [install.R](https://github.com/foen-admin-ch/groundwater-extreme-analysis/blob/main/install.R) file.
