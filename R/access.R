# High level functions for managing access control policies

#' Check and report access rules for a data package
#'
#' Check the access policy for the given subjects for the given package on a repository.
#'
#' @param pid (character) The PID identifier of the package to check permissions for.
#' @param subjects (character) List of subjects to be checked for the permissions
#' @param permissions (character) List of permissions (read, write, changePermission) to be checked
#' @param repo (character or MNode) The identifier of the repository as a string value, in which case it will be instantiated,
#' or as an instance of `dataone::MNode`
#' @return (data.frame) Listing the status of the access rules for each member of the package.
#'
#' @import dplyr
#' @import purrr
#' @import dataone
#' @import datapack
#' @import arcticdatautils
#' @export
#'
#' @examples
#'\dontrun{
#' pid <- "resource_map_urn:uuid:e788f9f8-8990-4440-882f-9f65deaa69f2"
#' ginny <- "http://orcid.org/0000-0002-7538-7081"
#' sme_group <- "CN=Sustainable Marine Ecosystems in Alaska Lab,DC=dataone,DC=org"
#' check_package_access(pid, subjects = c(ginny, sme_group),
#'     permissions = c("read", "write", "changePermission"))
#'
#'}
check_package_access <- function(pid, subjects, permissions=c("read", "write", "changePermission"), repo="urn:node:KNB") {
    mn <- get_repo(repo)
    pkg <- arcticdatautils::get_package(mn, pid)
    purrr::map_dfr(unlist(pkg), check_access, subjects=subjects, permissions=permissions, repo=mn)
}

#' Check and report access rules for an object
#'
#' Check the access policy for the given subjects for the given objects on a repository.
#'
#' @param pid (character) The PID identifier of the object to check permissions for.
#' @param subjects (character) List of subjects to be checked for the permissions
#' @param permissions (character) List of permissions (read, write, changePermission) to be checked
#' @param repo (character or MNode) The identifier of the repository as a string value, in which case it will be instantiated,
#' or as an instance of `dataone::MNode`
#' @return (data.frame) Listing the status of the access rules for each member of the package.
#'
#' @import dplyr
#' @import purrr
#' @import dataone
#' @import datapack
#' @export
#'
#' @examples
#'\dontrun{
#' pid <- "resource_map_urn:uuid:e788f9f8-8990-4440-882f-9f65deaa69f2"
#' ginny <- "http://orcid.org/0000-0002-7538-7081"
#' sme_group <- "CN=Sustainable Marine Ecosystems in Alaska Lab,DC=dataone,DC=org"
#' check_access(pid, subjects = c(ginny, sme_group),
#'     permissions = c("read", "write", "changePermission"))
#'
#'}
check_access <- function(pid, subjects, permissions = c("read", "write", "changePermission"), repo="urn:node:KNB") {
    mn <- get_repo(repo)
    sysmeta <- dataone::getSystemMetadata(mn, pid)
    missing_acl <- FALSE
    for (s in subjects) {
        for (p in permissions) {
            acls <- sysmeta@accessPolicy %>% filter(.data$subject==s, .data$permission==p)
            if (nrow(acls) < 1) {
                missing_acl <- TRUE
            }
        }
    }
    row <- c(status=ifelse(missing_acl, "Missing ACL", "Good"), pid=pid, file=sysmeta@fileName)
    return(row)
}

#' Add standard access rules for an object
#'
#' Add the access policy rules for the given subjects for the given objects on a repository.
#'
#' @param pid (character) The PID identifier of the object to check permissions for.
#' @param subjects (character) List of subjects to be checked for the permissions
#' @param permissions (character) List of permissions (read, write, changePermission) to be checked
#' @param repo (character or MNode) The identifier of the repository as a string value, in which case it will be instantiated,
#' or as an instance of `dataone::MNode`
#' @return (logical) Whether access rules needed to be added.
#'
#' @import arcticdatautils
#' @export
#'
#' @examples
#'\dontrun{
#' pid <- "resource_map_urn:uuid:e788f9f8-8990-4440-882f-9f65deaa69f2"
#' ginny <- "http://orcid.org/0000-0002-7538-7081"
#' sme_group <- "CN=Sustainable Marine Ecosystems in Alaska Lab,DC=dataone,DC=org"
#' add_package_access(pid, subjects = c(ginny, sme),
#'     permissions = c("read", "write", "changePermission"), repo="urn:node:KNB")
#'}
add_package_access <- function(pid, subjects, permissions = c("read", "write", "changePermission"), repo="urn:node:KNB") {
    mn <- get_repo(repo)
    pkg <- arcticdatautils::get_package(mn, pid)
    arcticdatautils::set_access(mn, unlist(pkg), subjects, permissions)
}

#' Get an instance of MNode for a repository string (or pass through a MNode)
#' @param repo (character or MNode) The identifier of the repository as a string value, in which case it will be instantiated,
#' or as an instance of `dataone::MNode`
#' @return (MNode) the repository as an instance of dataone::MNode
#' @importFrom methods is
get_repo <- function(repo) {
    if (is(repo, 'character')) {
        cn <- CNode()
        mn <- getMNode(cn,repo)
    } else if (class(repo) == "MNode") {
        mn <- repo
    } else {
        stop("repo must be either the character identifier of a DataONE repository, or an instance of dataone::MNode")
    }
}
