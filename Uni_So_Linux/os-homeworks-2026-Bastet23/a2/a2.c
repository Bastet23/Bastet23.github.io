#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include "a2_helper.h"
#include <semaphore.h>
#include <stdlib.h>
#include <fcntl.h>

#include <pthread.h>
#include <semaphore.h>
#include <stdalign.h>

sem_t start_t5;
sem_t end_t1;
sem_t sem4p3;
sem_t* semP2T3start;
sem_t* semP2T3end;
pthread_mutex_t mutexp3;
pthread_cond_t cond;
pthread_cond_t condOthers;
pthread_cond_t t14arrived;

int p3counter=0;
int t14present=0;
int t14finished=0;


void* threadFunctionP3(void* index)
{
    int localIndex=(int)(long) index;

    //toate threadurile asteapta dupa thread14
    pthread_mutex_lock(&mutexp3);
    while (!t14present)
        pthread_cond_wait(&t14arrived, &mutexp3);
    
    pthread_mutex_unlock(&mutexp3);

    sem_wait(&sem4p3);
    info(BEGIN, 3, localIndex);

    pthread_mutex_lock(&mutexp3);
    p3counter++;

    if (p3counter==4 && t14present)
        pthread_cond_broadcast(&cond);
    

    while(t14present && !t14finished)
        pthread_cond_wait(&condOthers, &mutexp3);
    p3counter--;
    pthread_mutex_unlock(&mutexp3);

   
    info(END, 3, localIndex);
    sem_post(&sem4p3);
    
    return index;
}

void* threadFunctionP3_14(void* index)
{
    sem_wait(&sem4p3);
    info(BEGIN, 3, 14);

    pthread_mutex_lock(&mutexp3);
    p3counter++;
    t14present++;

    //semnalizam ca t14 a ajuns
    pthread_cond_broadcast(&t14arrived);

    while(p3counter<4)
        pthread_cond_wait(&cond, &mutexp3);

    info(END, 3, 14);
    t14finished++;
    p3counter--;
    //semnalizam ca t 14 si-a incheiat executia
    pthread_cond_broadcast(&condOthers);

    pthread_mutex_unlock(&mutexp3);
    sem_post(&sem4p3);
    
    return index;
}

void* threadFunctionP6(void* index)
{
    int localIndex=(int)(long)index;

    if(localIndex==5)
        sem_wait(semP2T3end);

    info( BEGIN, 6, localIndex);

    info( END, 6, localIndex);

    if(localIndex==1)
        sem_post(semP2T3start);

    return index;
}

void* threadFunctionP2(void* index)
{
    int localIndex=(int)(long)(void*) index;

    if(localIndex==3)
        sem_wait(semP2T3start);

    info( BEGIN, 2, localIndex);
//
    info( END, 2, localIndex);

    if(localIndex==3)
        sem_post(semP2T3end);

    return index;
}

void* threadFunctionP2_T1(void* param)
{

    info(BEGIN, 2, 1);
        sem_post(&start_t5);
//
        sem_wait(&end_t1);
    info(END, 2 , 1);

    return param;
}

void* threadFunctionP2_T5(void* param)
{
        sem_wait(&start_t5);
    info(BEGIN,2, 5);
//
    info(END,2,5);
        sem_post(&end_t1);
    
        return param;
}



int main(){
    init();

    semP2T3start=sem_open("/RosuGalbenSiAlbastru", O_CREAT, 0644, 0);
    semP2T3end=sem_open("/RosuGalbenSiAlbastru", O_CREAT, 0644, 0);
    info(BEGIN, 1, 0);
    
    pid_t  pid2;

    pid2=fork();
    if(pid2==-1)
    {
        printf("Eroare la fork p2");
        return -2;
    }
    else if(pid2==0)
    {


        info(BEGIN, 2, 0);
        //procesul 2 trebuie facut p4 si p7
        //inainte de asta voi face threadurile pentru p2

        pthread_t tids[5];

        sem_init (&end_t1, 0, 0);
        sem_init (&start_t5, 0, 0);

        pthread_create(&tids[0], NULL, threadFunctionP2_T1, NULL);
        pthread_create(&tids[4], NULL, threadFunctionP2_T5, NULL);

        for(int i=1; i<4; i++)
        {
            pthread_create(&tids[i], NULL, threadFunctionP2, (void*)(long)(i+1));
        }

        for(int i=0; i<5; i++)
            pthread_join(tids[i],NULL);


        sem_destroy(&start_t5);
        sem_destroy(&end_t1);

        //incepe manufactura lui p4/p7
        pid_t  pid4;
        pid4=fork();
        if(pid4==-1)
        {
            printf("Eroare la fork p4");
            return -4;
        }
        else if(pid4==0)
        {
            info(BEGIN, 4, 0);
            //inside p4 trebuie facut p5 si p8
            pid_t  pid5;
            pid5=fork();
            if(pid5==-1)
            {
                printf("Eroare la fork p5");
                return -5;
            }
            else if(pid5==0)
            {
                //inside p5
                info(BEGIN, 5 ,0);

                info(END, 5, 0);

            }
            else
            {
                //inside p4 trebuie facut p8
                pid_t  pid8;
                pid8=fork();
                
                 if(pid8==-1)
                {
                    printf("Eroare la fork p8");
                    return -8;
                }
                else if(pid8==0)
                {
                    //inside p8
                    info(BEGIN, 8, 0);


                    info(END, 8, 0);
                }
                else{
                    //inside p4 we wait for p5 and p8

                    wait(NULL);
                    wait(NULL);

                    info(END, 4, 0);

                }

            }
        }
        else
        {
            //inside p2, trebuie facut p7
            pid_t  pid7;
            pid7=fork();
            if(pid7==-1)
            {
                printf("Eroare la fork p7");
                return -7;
            }
            else if(pid7==0)
            {
                info(BEGIN, 7, 0);
                //inside p7

                info(END, 7 , 0);
            }
            else
            {
                //inside p2

                //asteptam p7 si p4
                wait(NULL);
                wait(NULL);

                info(END, 2, 0);
            }
        }




    }
    else
    {
        //p1 parinte trebuie facut p3

        pid_t  pid3;

        pid3=fork();
        if(pid3==-1)
        {
            printf("Eroare la fork p3");
            return -3;
        }
        if(pid3==0)
        {
            info(BEGIN, 3, 0);
            //inside p3 trebuie facut p6
            //prima data threaduri p3

            sem_init(&sem4p3,0,4);
            pthread_mutex_init(&mutexp3,NULL);
            pthread_cond_init(&cond, NULL );
            pthread_cond_init(&condOthers, NULL );
            pthread_cond_init(&t14arrived, NULL );

            pthread_t tids3[38];

            for (int i=0; i<13; i++)
            {
                pthread_create(&tids3[i], NULL, threadFunctionP3, (void*)(long)(i+1));
            }

            pthread_create(&tids3[13],NULL, threadFunctionP3_14, NULL);
            
            for (int i=14; i<38; i++)
            {
                pthread_create(&tids3[i], NULL, threadFunctionP3, (void*)(long)(i+1));
            }

            for(int i=0; i<38; i++)
            {
                pthread_join(tids3[i], NULL);
            }

            sem_destroy(&sem4p3);
            pthread_mutex_destroy(&mutexp3);
            pthread_cond_destroy(&cond);
            pthread_cond_destroy(&condOthers);
            pthread_cond_destroy(&t14arrived);
            

            //abia acum facem p6
            pid_t  pid6;

            pid6=fork();
            if(pid6==-1)
            {
                printf("Eroare la fork p6");
                return -6;
            }
            if(pid6==0)
            {
                info(BEGIN, 6, 0);
                //ii creem threadurile aferente


                pthread_t tidsP6[6];

                for(int i=0; i<6; i++)
                {
                    pthread_create(&tidsP6[i], NULL, threadFunctionP6, (void*)(long)(i+1));
                }

                for(int i=0; i<6; i++)
                {
                    pthread_join(tidsP6[i], NULL);
                }


                //distrugem semaphoarele
                sem_close(semP2T3start);
                sem_close(semP2T3end);
                sem_unlink("/RosuGalbenSiAlbastru");
                //inside p6
                info(END, 6, 0);
            }
           
            //inside p3

            //wait for p6 to finish
            wait(NULL); //we don't care about the status
            
            info(END, 3, 0);
        }
        //inside p1 trebuie sa asteptam terminarea p2 si p3 deci 2 wait -uri

        wait(NULL);
        wait(NULL);
        info(END, 1, 0);//schimbat de la return 0 aici ca sa fie apelat exclusiv de p1    
    }

    
    return 0;
}
