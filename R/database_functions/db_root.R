# Find the database root path
# Written by June Skeeter March 2024

library("yaml")

# To find database_default from inside (the root) of a project folder
get_biomet_default <- function(fn="Matlab/biomet_database_default.m"){
    # Read .m file as "text"
    config <- paste(readLines(fn), collapse="\n")
    # Identify system, translate Matlab to Python, and evaluate
    config <- gsub('%','#',as.character(config))
    config <- gsub('\\\\','/',as.character(config))
    config <- strsplit(config,"if ispc")[[1]][2]
    config <- strsplit(config,"elseif ismac")[[1]]
    if(.Platform$OS.type == "unix") {
        eval(parse(text=config[2]))
    } else {
        eval(parse(text=config[1]))
    }
    return(x)
}
        
get_config <- function(fn='_config.yml'){
    config <- yaml.load_file(fn)
    return(config$Database$root)
    }


config_fn = '_config.yml'
matlab_fn = 'Matlab/biomet_database_default.m'
{
# 1 Search for _config.yml in root of Project Folder
if (file.exists(config_fn)){
    db_root <- get_config(config_fn)
}
# 2 Search for matalab default in root of project folder
else if (file.exists(matlab_fn)) {
    db_root <- get_biomet_default(matlab_fn)
}
# 3 Search environment variables for UBC_PC_Setup
# Repeat 1 & 2, prompt for input as last resort
else {
    A <- 'UBC_PC_Setup'
    B <- unname(Sys.getenv(names='True'))
    pth <- setNames(lapply(A, function(x) grep(x, B, value = TRUE)), A)
    print(identical(unname(pth)[[1]], character(0)))
    if (!identical(unname(pth)[[1]], character(0))){
        if (file.exists(file.path(pth,config_fn))){
            db_root <- get_config(file.path(pth,config_fn))
        }else if (file.exists(file.path(pth,matlab_fn))) {
            db_root <- get_biomet_default(file.path(pth,matlab_fn))
        }
    }else{
        cat("No default database path found, input path to database: ")
        db_root <- readLines(con = "stdin", n = 1)
    }
}
}


setwd('C:/Users/User/MyProject')
print(script_path <- as.character(sys.frame(1)$ofile))
# p <- sapply(list.files(pattern="read_database.R",path='C:/Biomet.net/R/database_functions',full.names=TRUE), source)
# p <- sapply(list.files(pattern="read_database.R",full.names=TRUE), source)
# source('read_database.R')
# read_database('C:/Database',2024,'BB','Clean/SecondStage','TA_1_1_1','clean_tv',0)
