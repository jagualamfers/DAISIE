% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DAISIE_area_params.R
\name{create_area_params}
\alias{create_area_params}
\title{Create named list of area parameters}
\usage{
create_area_params(max_area, proportional_peak_t, peak_sharpness,
  total_island_age)
}
\arguments{
\item{max_area}{maximum area}

\item{proportional_peak_t}{value from 0 to 1 indicating where in the island's history the 
peak area is achieved}

\item{peak_sharpness}{sharpness of peak}

\item{total_island_age}{total island age}
}
\value{
list of numerical values containing area parameters for island ontogeny 
simulation
}
\description{
Create named list of area parameters
}
\examples{
testit::assert(DAISIE:::are_area_params(
create_area_params(
  max_area = 10,
  proportional_peak_t = 0.5,
  peak_sharpness = 1,
  total_island_age = 5
      )
    )
  )
}
