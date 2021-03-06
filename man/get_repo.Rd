% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/access.R
\name{get_repo}
\alias{get_repo}
\title{Get an instance of MNode for a repository string (or pass through a MNode)}
\usage{
get_repo(repo)
}
\arguments{
\item{repo}{(character or MNode) The identifier of the repository as a string value, in which case it will be instantiated,
or as an instance of \code{dataone::MNode}}
}
\value{
(MNode) the repository as an instance of dataone::MNode
}
\description{
Get an instance of MNode for a repository string (or pass through a MNode)
}
