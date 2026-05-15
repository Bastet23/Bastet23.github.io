#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h>



int listHelper(int recursive, char* path, char* nameStartsWith, mode_t permissions, char*needsPermissions)
{

    DIR* dir=NULL;
    struct dirent* entry=NULL;
    char filePath[512];
    struct stat statbuf;

    dir=opendir(path);
    if(dir==NULL){
        printf("Invalid directory path\n");
        return 14;
    }

    int error=0;

    while((entry=readdir(dir))!=NULL){
        if(strcmp(entry->d_name, ".")!=0 && strcmp(entry->d_name, "..")!=0)
        {
            snprintf(filePath,512, "%s/%s", path, entry->d_name);
            if(lstat(filePath, &statbuf)==0)
            {
                if(nameStartsWith!=NULL)
                {
                    if(strncmp(entry->d_name, nameStartsWith, strlen(nameStartsWith)) == 0) 
                    printf("%s\n", filePath);
                }
                else if(needsPermissions){
                    if((statbuf.st_mode & 0777)==permissions)
                    printf("%s\n", filePath);
                }
                else{
                    printf("%s\n", filePath);
                }
                
                if(S_ISDIR(statbuf.st_mode) && recursive==1){
                    int currentError=listHelper(recursive,filePath,nameStartsWith,permissions, needsPermissions);
                    if(currentError)
                    error=currentError;
                }
            
            }
            else
            {
                printf("Error\nEroare la lstat");
                error=15;
            }
        }
    }

    closedir(dir);
    return error;

}


int list(int argc, char **argv){
    
    if(argc>5)
    {
        printf("ERROR\nNumar prea mare de argumente\n");
        return 11;
    }

    int recursive=0; 
    char* nameStartsWith=NULL; 
    char* permissions=NULL; 
    char* path=NULL;
    char* token;

    if(strcmp(argv[2], "recursive")==0)
        recursive=1;

    
    int i=2+recursive;

    if(i<argc-1)
    {
        token=strtok(argv[i], "=");

        if(strcmp(token, "name_starts_with")==0){
            token=strtok(NULL,"=");
            nameStartsWith=token;

            //printf("%s\n", nameStartsWith);
        }
        else if(strcmp(token, "permissions")==0)
        {
            token=strtok(NULL,"=");
            permissions=token;
            //printf("%s\n", permissions);
            if(strlen(permissions)!=9)
            {
                printf("ERROR\n permisiuni non standard");
            return 121;}

        }

        else{
            printf("ERROR\nArgumente de filtrare invalide\n");
            return 12;
        }
    }
    
    mode_t targetPermissions=0;
    if(permissions!=NULL)
    {
        if(permissions[0]=='r') targetPermissions+=0400;
        if(permissions[1]=='w') targetPermissions+=0200;
        if(permissions[2]=='x') targetPermissions+=0100;
    
        if(permissions[3]=='r') targetPermissions+=0040;
        if(permissions[4]=='w') targetPermissions+=0020;
        if(permissions[5]=='x') targetPermissions+=0010;
    
        if(permissions[6]=='r') targetPermissions+=0004;
        if(permissions[7]=='w') targetPermissions+=0002;
        if(permissions[8]=='x') targetPermissions+=0001;

    }
    
    token=strtok(argv[argc-1], "=");
    
    if(strcmp(token,"path")==0){
        token=strtok(NULL,"=");
        path=token; 
        //printf("%s\n", path);
    }
    else{
        printf("ERROR\nSpecificati dupa formatul path=nume_path\n");
        return 13;
    }

    int error;

    //litlle check ca sa nu printez succes si apoi eroare la path
    DIR* dir=NULL;
    dir=opendir(path);
    if(dir==NULL){
        printf("Invalid directory path\n");
        return 14;
    }
    closedir(dir);

    printf("SUCCESS\n");

    if(path)
        error=listHelper(recursive,path,nameStartsWith,targetPermissions, permissions);

    return error;

}
//parseHelper size cap
int parseHelperSizeCap(char* path){

    int fd1=-1;

    fd1= open(path, O_RDONLY);
    if(fd1==-1){
        
        close(fd1);
        return 23;
    }

    char magic[5];
    lseek(fd1, -4,SEEK_END);
    read(fd1,magic,4);

    magic[4]=0;
    //printf("%s", magic);

    if(strcmp(magic,"zQVb")!=0)
    {
        
        close(fd1);
        return 24;
    }

    int headerSize=0;
    lseek(fd1,-6, SEEK_END);
    read(fd1,&headerSize,2);

    lseek(fd1,-headerSize,SEEK_END);

    int version=0;
    int nrOfSections=0;

    read(fd1, &version, 1);
    read(fd1, &nrOfSections, 1);

    if(version<103 || version >207)
    {
        
        close(fd1);
        return 25;
    }      

    if(!(nrOfSections==2 || (nrOfSections>=6 && nrOfSections<=17)))
    {
        
        close(fd1);
        return 26;
    }      


    char names[nrOfSections][20];
    int types[nrOfSections];
    int sizes[nrOfSections];
    for(int i=0; i<nrOfSections; i++)
    {
        read(fd1, names[i],19);
        read(fd1, &types[i],4);
        lseek(fd1,4,SEEK_CUR);
        read(fd1, &sizes[i],4);

        names[i][19]=0;
        
        if(types[i]!=63 &&types[i]!=85 &&types[i]!=40 &&types[i]!=45 &&types[i]!=77 &&types[i]!=99)
        {
        
        close(fd1);
        return 27;
        }
        
        if(sizes[i]>1195)
        {
            
            close(fd1);
        return 27;
    }

    }

    close(fd1);
    return 0;
}



//parseHelper no print
int parseHelperNoPrint(char* path){

    int fd1=-1;

    fd1= open(path, O_RDONLY);
    if(fd1==-1){
        printf("ERROR\nEroare la deschiderea fisierului");
        return 23;
    }

    char magic[5];
    lseek(fd1, -4,SEEK_END);
    read(fd1,magic,4);

    magic[4]=0;
    //printf("%s", magic);

    if(strcmp(magic,"zQVb")!=0)
    {
        printf("ERROR\nwrong magic\n");
        close(fd1);
        return 24;
    }

    int headerSize=0;
    lseek(fd1,-6, SEEK_END);
    read(fd1,&headerSize,2);

    lseek(fd1,-headerSize,SEEK_END);

    int version=0;
    int nrOfSections=0;

    read(fd1, &version, 1);
    read(fd1, &nrOfSections, 1);

    if(version<103 || version >207)
    {
        printf("ERROR\nwrong version\n");
        close(fd1);
        return 25;
    }      

    if(!(nrOfSections==2 || (nrOfSections>=6 && nrOfSections<=17)))
    {
        printf("ERROR\nwrong sect_nr\n");
        close(fd1);
        return 26;
    }      


    char names[nrOfSections][20];
    int types[nrOfSections];
    int sizes[nrOfSections];
    for(int i=0; i<nrOfSections; i++)
    {
        read(fd1, names[i],19);
        read(fd1, &types[i],4);
        lseek(fd1,4,SEEK_CUR);
        read(fd1, &sizes[i],4);

        names[i][19]=0;
        
        if(types[i]!=63 &&types[i]!=85 &&types[i]!=40 &&types[i]!=45 &&types[i]!=77 &&types[i]!=99)
        {
        printf("ERROR\nwrong sect_types\n");
        close(fd1);
        return 27;
        }      
    }
    close(fd1);
    return 0;
}

int parseHelper(char* path){

    int fd1=-1;

    fd1= open(path, O_RDONLY);
    if(fd1==-1){
        printf("ERROR\nEroare la deschiderea fisierului");
        return 23;
    }

    char magic[5];
    lseek(fd1, -4,SEEK_END);
    read(fd1,magic,4);

    magic[4]=0;
    //printf("%s", magic);

    if(strcmp(magic,"zQVb")!=0)
    {
        printf("ERROR\nwrong magic\n");
        return 24;
    }

    int headerSize=0;
    lseek(fd1,-6, SEEK_END);
    read(fd1,&headerSize,2);

    lseek(fd1,-headerSize,SEEK_END);

    int version=0;
    int nrOfSections=0;

    read(fd1, &version, 1);
    read(fd1, &nrOfSections, 1);

    //  printf("%d\n\n", version);
    //   printf("%d\n\n", nrOfSections);

    if(version<103 || version >207)
    {
        printf("ERROR\nwrong version\n");
        return 25;
    }      

    if(!(nrOfSections==2 || (nrOfSections>=6 && nrOfSections<=17)))
    {
        printf("ERROR\nwrong sect_nr\n");
        return 26;
    }      


    char names[nrOfSections][20];
    int types[nrOfSections];
    int sizes[nrOfSections];


    for(int i=0; i<nrOfSections; i++)
    {
        read(fd1, names[i],19);
        read(fd1, &types[i],4);
        lseek(fd1,4,SEEK_CUR);
        read(fd1, &sizes[i],4);

        names[i][19]=0;
        
        if(types[i]!=63 &&types[i]!=85 &&types[i]!=40 &&types[i]!=45 &&types[i]!=77 &&types[i]!=99)
        {
        printf("ERROR\nwrong sect_types\n");
        return 27;
        }      
    }


    printf("SUCCESS\n");
    printf("version=%d\nnr_sections=%d\n", version, nrOfSections);
    for(int i=0; i<nrOfSections; i++)
    printf("section%d: %s %d %d\n", i+1, names[i], types[i], sizes[i]);

    return 0;
}

int parse(int argc, char **argv){

    if(argc!=3)
    {
        printf("ERROR\n Numar invalid de argumente\n");
        return 21;
    }

    char* path=NULL;
    if(strcmp(argv[1],"parse")==0)
        path=argv[2];
    else
        path=argv[1];

    char* token=strtok(path, "=");
    
    if(strcmp(token,"path")==0){
        token=strtok(NULL,"=");
        path=token; 
    }
    else{
        printf("ERROR\nSpecificati dupa formatul path=nume_path\n");
        return 22;
    }

    //printf("%s", path);

    int error=0;

    error=parseHelper(path);

    return error;
}

int extractHelper(char*path, int section, int line){

    int fileOk=parseHelperNoPrint(path);
    if(fileOk!=0)
    {
        printf("ERROR\n Invalid file type\n");
        return 355;
    }

    int fd1=-1;

    fd1= open(path, O_RDONLY);
    if(fd1==-1){
        printf("ERROR\nEroare la deschiderea fisierului");
        return 36;
    }

    int headerSize=0;
    lseek(fd1,-6, SEEK_END);
    read(fd1,&headerSize,2);

    lseek(fd1,-(headerSize-1),SEEK_END);

    int nr_sect=0;
    read(fd1,&nr_sect,1);
    if(section>nr_sect)
    {
        printf("ERROR\nSectorul ales nu exista");
        return 365;

    }

    lseek(fd1, 31*(section-1), SEEK_CUR);
    lseek(fd1, 23, SEEK_CUR);

    int offset=0;
    int sectSize=0;
    read(fd1,&offset, 4);
    read(fd1,&sectSize, 4);

    lseek(fd1,offset,SEEK_SET);
    char* buffer=(char*)calloc(sectSize, sizeof(char));
    read(fd1, buffer,sectSize);
    
    int lineCnt=1;
    int start=0;
    int end=sectSize;

    for(int i= sectSize-1; i>=0; i--)
    {
        if(buffer[i]=='\x0a'){
            if(lineCnt==line)
            {
                start=i+1;
                break;
            }
            lineCnt++;
            
            end=i;
        }
    }

    if(line>lineCnt)
    {
        printf("ERROR\nLinia ceruta nu exista");
        return 37;
    }


    printf("SUCCESS\n");
    for(int i=start; i<end; i++)
    {
        printf("%c",buffer[i]);
    }

    printf("\n");

    free(buffer);
    return 0;
}

int extract(int argc, char **argv){

    char* path=NULL;
    int section;
    int line;

    if(argc!=5)
    {
        printf("ERROR\n Numar invalid de argumente\n");
        return 31;
    }

    char* token=strtok(argv[2], "=");
    
    if(strcmp(token,"path")==0){
        token=strtok(NULL,"=");
        path=token; 
    }
    else{
        printf("ERROR\nSpecificati dupa formatul path=nume_path\n");
        return 33;
    }

    token=strtok(argv[3], "=");
    
    if(strcmp(token,"section")==0){
        token=strtok(NULL,"=");
        sscanf(token,"%d", &section); 
    }
    else{
        printf("ERROR\nSpecificati dupa formatul section=<section>\n");
        return 34;
    }
    token=strtok(argv[4], "=");
    
    if(strcmp(token,"line")==0){
        token=strtok(NULL,"=");
         sscanf(token,"%d", &line); 
    }
    else{
        printf("ERROR\nSpecificati dupa formatul line=<line>\n");
        return 35;
    }


    int error=0;

    error=extractHelper(path, section, line);

    return error;

}

int findallHelper(char* path){

     DIR* dir=NULL;
    struct dirent* entry=NULL;
    char filePath[512];
    struct stat statbuf;

    int error=0;

    dir=opendir(path);
    if(dir==NULL){
        printf("Invalid directory path\n");
        return 54;
    }

    while((entry=readdir(dir))!=NULL){
        if(strcmp(entry->d_name, ".")!=0 && strcmp(entry->d_name, "..")!=0)
        {
            snprintf(filePath,512, "%s/%s", path, entry->d_name);
            if(lstat(filePath, &statbuf)==0)
            {
                
                if(S_ISREG(statbuf.st_mode)) {
                    int fileOk = parseHelperSizeCap(filePath);
                    if(fileOk == 0) {
                    printf("%s\n", filePath); 
                    }
                }
                
                if(S_ISDIR(statbuf.st_mode) ){
                    int currentError=findallHelper(filePath);
                    if(currentError)
                    error=currentError;
                }
            
            }
            else
            {
                printf("Error\nEroare la lstat");
                error=55;
            }
        }
    }

    closedir(dir);

    return error;
}

int findall(int argc, char **argv){

    int error=0;
    char* path=NULL;


    if(argc!=3)
    {
        printf("ERROR\n Numar invalid de argumente\n");
        return 41;
    }

    char* token=strtok(argv[2], "=");
    
    if(strcmp(token,"path")==0){
        token=strtok(NULL,"=");
        path=token; 
    }
    else{
        printf("ERROR\nSpecificati dupa formatul path=nume_path\n");
        return 43;
    }

    printf("SUCCESS\n");
    error=findallHelper(path);

    
    return error;
}




int main(int argc, char **argv)
{

    int error=0;
    if( argc >= 3){
        if(strcmp(argv[1], "list") == 0) {
            error=list( argc, argv);
            
        }
        if(strcmp(argv[1], "parse") == 0 || strncmp(argv[1],"path",strlen("path"))==0) {
            error=parse( argc, argv);
            
        }
        if(strcmp(argv[1], "extract") == 0) {
            error=extract( argc, argv);
            
        }
        if(strcmp(argv[1], "findall") == 0) {
            findall( argc, argv);
            
        }
    }

    else if(argc >= 2) {
        if(strcmp(argv[1], "variant") == 0) {
            printf("32686\n");
        }
        else
        {
            printf("Numar invalid de parametrii");
            return 100;
        }
    }

    else{
        printf("Numar invalid de parametrii");
        return 100;
    }
        
    
    
        return error;
    }
    
