# High level functions for managing access control policies

#' Check and report access rules for a package
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
#' sme <- "CN=Sustainable Marine Ecosystems in Alaska Lab,DC=dataone,DC=org"
#' check_access(pid, subjects = c(ginny, sme), permissions = c("read", "write", "changePermission"))
#'
#'}
check_access <- function(pid, subjects, permissions, repo="urn:node:KNB") {
    mn <- get_repo(repo)
    sysmeta <- dataone::getSystemMetadata(mn, pid)
    missing_acl <- FALSE
    for (subject in subjects) {
        for (permission in permissions) {
            acls <- sysmeta@accessPolicy %>% filter(subject == subject, permission == permission)
            if (nrow(acls) < 1) {
                mising_acl <- TRUE
            }
        }
    }
    return(c(status=ifelse(missing_acl, "Missing ACL", "Good"), pid=pid, file=sysmeta@fileName))
}

#' Set the access policy for an object
#'
#' Set the access policy for the given subjects for the given objects on the given Member Node.
#' For each type of permission, this function checks if the permission is already set
#' and only updates the System Metadata when a change is needed.
#'
#' @param pids (character) The PIDs of the objects to set permissions for.
#' @param subjects (character) The identifiers of the subjects to set permissions for, typically an ORCID or DN.
#' @param permissions (character) Optional. The permissions to set. Defaults to
#'   read, write, and changePermission.
#' @param repo (character or MNode) The identifier of the repository as a string value, in which case it will be instantiated,
#' or as an instance of `dataone::MNode`
#'
#' @return (logical) Whether an update was needed.
#'
#' @export
#'
#' @examples
#'\dontrun{
#' pids <- c("urn:uuid:3e5307c4-0bf3-4fd3-939c-112d4d11e8a1",
#'           "urn:uuid:23c7cae4-0fc8-4241-96bb-aa8ed94d71fe")
#' set_access(pids, subjects = ginny,
#'            permissions = c("read", "write", "changePermission"))
#'}
set_access <- function(pids, subjects, permissions = c("read", "write", "changePermission"), repo="urn:node:KNB") {
    mn <- get_repo(repo)

    if (!all(is.character(pids),
             all(nchar(pids) > 0))) {
        stop("Argument 'pids' must be character class with non-zero number of characters.")
    }

    if (!all(is.character(subjects),
             all(nchar(subjects)) > 0)) {
        stop("Argument 'subjects' must be character class with non-zero number of characters.")
    }

    if (grepl("^https:\\/\\/orcid\\.org", subjects)) {
        subjects <- gsub("^https:\\/\\/orcid\\.org", "http:\\/\\/orcid\\.org", subjects)
        message("Subject contains https, transforming to http")
    }

    if (!all(permissions %in% c("read", "write", "changePermission"))) {
        stop("Argument 'permissions' must be one or more of: 'read', 'write', 'changePermission'")
    }


    result <- c()

    for (pid in pids) {
        changed <- FALSE

        sysmeta <- tryCatch({
            dataone::getSystemMetadata(mn, pid)
        }, warning = function(w) {
            message(paste0("Failed to get System Metadata for PID '", pid, "'\non MN '", mn@endpoint, "'.\n"))
            w
        }, error = function(e) {
            message(paste0("Failed to get System Metadata for PID '", pid, "'\non MN '", mn@endpoint, "'.\n"))
            message(e)
            e
        })

        if (!inherits(sysmeta, "SystemMetadata")) {
            stop("Failed to get System Metadata.")
        }

        for (subject in subjects) {
            for (permission in permissions) {
                if (!datapack::hasAccessRule(sysmeta, subject, permission)) {
                    sysmeta <- datapack::addAccessRule(sysmeta, subject, permission)
                    changed <- TRUE
                }
            }
        }

        if (changed) {
            result[pid] <- TRUE
            message(paste0("Updating System Metadata for ", pid, "."))
            dataone::updateSystemMetadata(mn, pid, sysmeta)
        } else {
            result[pid] <- FALSE
        }
    }

    # Name the result vector
    names(result) <- pids

    result
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
    } else if (is(repo, dataone::MNode)) {
        mn <- repo
    } else {
        stop("repo must be either the character identifier of a DataONE repository, or an instance of dataone::MNode")
    }
}
