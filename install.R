# This file contains packages which should be added to the notebook
# during the build process. It is standard R code which is run during
# the build process and typically comprises a set of `install.packages()`
# commands.
#
# For example, remove the comment from the line below if you wish to
# install the `ggplot2` package.
#

# For easy date manipulation
install.packages('lubridate')

#To fit Extreme Value Distributions using maximum likelihood
install.packages('evd')

# To fit parametric models using l-moment matching
install.packages('lmom')

# To estimate automatically trends from data
install.packages('mgcv')

# To create simple and beautiful plots
install.packages('ggplot2')

# To manipulate tabular data efficiently
install.packages('dplyr')

# To define plotting areas 
install.packages('repr')
