DESCRIPTION
    Despite the growing popularity of U.S. national parks, there currently lacks a single source that provides a comprehensive visualization of each U.S. national park and their visitation.
    Our project provides a solution that allows users to easily view and interpret historical visitation numbers, as well as forecast future visitation numbers, for multiple parks at once.
    
    The working, deployed solution is available as a Tableau dasbhoard that is hosted on Tableau Public at this URL:
         https://public.tableau.com/app/profile/priyal.patel/viz/NationalParkVisitation_16689901476680/Sheet1
    
    End users only need to navigate to the link provided above to interact with our solution. However, we are providing the additional materials that were created in order to arrive at the
    final Tableau dashboard. Should this project be open-sourced, the resources provided in the CODE directory should be sufficient enough to continue the effort.

    The provided additional material is available in the CODE directory and is organized into multiple subdirectories:
        - /CODE/arima_model:
            - location_data.ipynb
                This jupyter notebook contains the code used to merge/append latitude and longitude columns to each national park's visitation data. The merged dataset is exported as
                Data_Final.csv.
                The original NPS data set was downloaded from the NPS website:
                https://irma.nps.gov/STATS/SSRSReports/National%20Reports/Query%20Builder%20for%20Public%20Use%20Statistics%20(1979%20-%20Last%20Calendar%20Year)

            - Location.csv
                The 'Location.csv' contains the latitude and longitude for each national park. Downloaded from Kaggle here:
                https://www.kaggle.com/code/regionalbird/national-parks/data

            - Project6242_TimeSeries.ipynb
                This contains the code used to visualize and process the data, as well as training and testing the Seasonal ARIMA model. 
                In the jupyter notebook, the dataset that was created in locatioN_data.ipynb was downloaded and referred to at path `F:\CSE 6242\Project\Data_Final.csv`. Feel free to change 
                the project directory path to match your local structure. Similarly, output files and images are written to `F:\CSE 6242\Project`.

            - 6242_Project_Arima_Forecast_Error.ipynb
                This contains the code used to further evaluate the various {parkname}.csv files that were created when running Project6242_TimeSeries.ipynb 
                against the dataset (Data_Final.csv).Project6242_TimeSeries.ipynb must be ran prior to this file being run. As with Project6242_TimeSeries.ipynb, 
                output files and images are written to `F:\CSE 6242\Project`.

        - /CODE/holt_winters:
            - National_Park_Forecast.R
                This contains the R code used to train and test the Holt-Winters model (which we ultimately did not use in the final tableau visualization).
                Uses the Data_Final.csv file that was created via location_data.ipynb. In the .R file, the dataset was placed in `C:/Users/olivi/Downloads/Data_Final.csv`, 
                predictions and evaluation files were written to `C:/Users/olivi/Downloads/`, but adjust accordingly to your local structure.

        - /CODE/tableau_files:
            - Data_w_ARIMA_forecasts.csv
                This is the .csv file that contains the data that was fed into Tableau for visualization.
            - Data_w_ARIMA_forecasts.hyper
                This contains the same data as Data_w_ARIMA_forecasts, but is in the .hyper extract format, which Tableau uses for faster data ingestion and analytical querying
                of large/copmlex data sets.

INSTALLATION
    End users should not need to install anything, as the final solution is hosted. 

    However, to recreate the modeling experiments/evaluation:
        - For the Python jupyter notebook files, Python 3.x must be installed. pip install from /Code/arima_model/requirements.txt.
        - For the R file, R 3.4+ must be installed. Specific library nstallation commands are included in the R code, so no prior installation is needed.
        
EXECUTION
    End users only need to navigate to the hosted URL to view/interact with the Tableau dashboard.

    However, to recreate the modeling experiments/evaluation:
    - For the Python jupyter notebook files, after installing requirements, launch a Jupyter notebook server and run cells accordingly.
    - For the R file, the file can be ran interactively via R Studio or VSCode or via command line.