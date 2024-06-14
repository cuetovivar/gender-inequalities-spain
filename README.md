# Gender Inequalities in Spain: Selection into Employment and the Wage Gap

Overview
--------

This replication package reproduces all the results in "Gender Inequalities in Spain: Selection into Employment and the Wage Gap," starting from raw data preparation to the final results. The entire code may take 2 to 3 weeks to run, mainly due to the bootstrap, but many parts can be run independently.

If you spot any mistake or have any questions, please email: cuetovivar@gmail.com.

Data availability
-----------------

All the data comes from the cross-sections of the _Encuesta de Condiciones de Vida_ for the period 2017-2023, developed by the Spanish National Institute of Statistics (INE). The microdata is publicly available at [INE's website](https://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736176807&menu=resultados&idp=1254735976608#_tabs-1254736195153), but cannot be redistributed directly.

Computational requirements
---------------------------

### Software

The code was written and run using Stata/SE 17.0, but earlier and later versions should also work.

### Commands

Parts of the code use the `qregsel` command developed by [Muñoz and Siravegna (2021)](https://journals.sagepub.com/doi/10.1177/1536867X211063148).

### Details

The code was run on a 2.8 GHz 4-Core Intel Core i7-1165G7 laptop with Windows 11 version 23H2 and 16 GB of RAM.

Code description
----------------

The code is included in the folder `Stata` and divided into 6 do files plus a master do file that executes all the code.

- `Stata/00_Master.do` runs all the code.
- `Stata/01_Data_Preparation.do` creates the sample.
- `Stata/02_Descriptive_Analysis.do` obtains different descriptive statistics.
- `Stata/03_Propensity_Score.do` estimates the propensity score using a Probit model.
- `Stata/04_QSR.do` estimates the quantile selection model of [Arellano and Bonhomme (2017)](https://onlinelibrary.wiley.com/doi/abs/10.3982/ECTA14030).
- `Stata/05_QSR_Bootstrap.do` performs the bootstrap to obtain the standard error of the copula parameter.
- `Stata/06_Corrected_Inequality.do` computes corrected measures of wage and gender inequality.

Instructions for replication
----------------------------

- Create a folder named `Data` with two subfolders: `Raw` and `Temporary`.
- The original data from the _Encuesta de Condiciones de Vida_ must be stored in `Data/Raw`.
- Create a folder named `Log`, where numerical results will be stored.
- Create a folder named `Figures`, where figures will be stored.
- Run `Stata/00_Master.do`.

List of tables and figures
--------------------------

The code in this replication package produces:

- [x] All tables in the paper.
- [x] All figures in the paper.

Tables are stored in `Log`and figures in `Figures`.

| Table/Figure | Do file | Output file |
|---|---|---|
| Table 1 | `Stata/02_Descriptive_Analysis.do` | `Log/Descriptive_Statistics.log` |
| Table 2 | `Stata/02_Descriptive_Analysis.do` | `Log/Descriptive_Statistics.log` |
| Table 3 | `Stata/02_Descriptive_Analysis.do` | `Log/Observed_Wage_Gap.log` |
| Table 4 | `Stata/03_Propensity_Score.do` | `Log/Average_Propensity_Score.log` |
| Table 5 | `Stata/04_QSR.do` and `Stata/05_QSR_Bootstrap.do` | `Log/QSR_Females_'year'.log`, `Log/QSR_Males_'year'.log`, `Log/QSR_Females_Bootstrap.log` and `Log/QSR_Males_Bootstrap.log` |
| Table 6 | `Stata/06_Corrected_Inequality.do` | `Log/Corrected_Wage_Inequality.log` |
| Figure 1 | `Stata/06_Corrected_Inequality.do` | `Figures/Quantile_'q'th.png` |

References
-----------------

Arellano, Manuel and Bonhomme, Stéphane (2017): Quantile Selection Models With an Application to Understanding Changes in Wage Inequality. _Econometrica_, 85(1), 1-28.

Muñoz, Ercio and Siravegna, Mariel (2021): Implementing Quantile Selection Models in Stata. _The Stata Journal_, 21(4), 952-971.
