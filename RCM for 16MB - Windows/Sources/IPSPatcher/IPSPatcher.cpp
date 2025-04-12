
/*
                tiny simple in-memory ips-patcher 

    This program allows you to apply an IPS format patch
    file to a binary file. The original source can be found
    at this address https://github.com/mrehkopf/ips/tree/master
    It has been slightly modified to be compiled with
    Visual Studio.

*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define _CRT_SECURE_NO_WARNINGS

uint32_t read24(FILE* fp) {
    uint32_t value = 0;
    value |= (fgetc(fp) << 16);
    value |= (fgetc(fp) << 8);
    value |= (fgetc(fp));
    return value;
}

uint16_t read16(FILE* fp) {
    uint16_t value = 0;
    value |= (fgetc(fp) << 8);
    value |= (fgetc(fp));
    return value;
}

int main(int argc, char** argv) {
    FILE* fd, * ips;
    char* buffer = NULL;
    char ipsbuf[5];
    long offset = 0;
    size_t cursize = 0;
    size_t lastsize = 0;
    char* off_endptr;

    int32_t ipsaddr = 0;
    size_t ipsflen = 0;
    uint16_t ipssize = 0;
    uint32_t ipsrlen = 0;

    /* display usage */
    if (argc < 4 || argc > 5) {
        fprintf(stderr, "Usage: %s <infile> <ipsfile> <outfile> [offset]\n", argv[0]);
        fprintf(stderr, "offset is a signed offset applied to all addresses specified in the patch\n");
        fprintf(stderr, "it may be given in decimal (-512), hex (-0x200), or octal (-01000)\n");
        exit(1);
    }

    /* parse offset option */
    if (argc >= 5) {
        offset = strtol(argv[4], &off_endptr, 0);
        if (*off_endptr) {
            fprintf(stderr, "Invalid offset: %s (first invalid char: '%c')\n", argv[4], *off_endptr);
            exit(1);
        }
        printf("Using offset: %s\n", argv[4]);
    }

    /* open input file */
    if (fopen_s(&fd, argv[1], "rb") != 0) {
        perror("cannot open input file");
        exit(1);
    }

    /* open IPS file */
    if (fopen_s(&ips, argv[2], "rb") != 0) {
        perror("cannot open IPS file");
        exit(1);
    }

    /* get IPS file size */
    fseek(ips, 0, SEEK_END);
    ipsflen = ftell(ips);
    fseek(ips, 0, SEEK_SET);

    /* check if the IPS header is valid */
    fread(ipsbuf, 5, 1, ips);
    if (memcmp("PATCH", ipsbuf, 5)) {
        fprintf(stderr, "Invalid IPS file\n");
        exit(1);
    }

    /* read entire input file into memory */
    fseek(fd, 0, SEEK_END);
    cursize = ftell(fd);
    lastsize = cursize;
    fseek(fd, 0, SEEK_SET);
    if ((buffer = (char*)malloc(cursize)) == NULL) {
        fprintf(stderr, "could not reserve memory\n");
        exit(1);
    }
    fread(buffer, cursize, 1, fd);
    fclose(fd);

    /* perform IPS patching */
    while (1) {
        ipsaddr = read24(ips);
        if (feof(ips)) {
            fprintf(stderr, "unexpected end of IPS file\n");
            break;
        }
        /* end tag */
        if (ipsaddr == 0x454f46 && static_cast<long>(ftell(ips)) >= static_cast<long>(ipsflen - 3)) {
            printf("EOF");
            if (ftell(ips) == (ipsflen - 3)) {
                lastsize = cursize;
                cursize = read24(ips);
                printf(", padding to size %06zu\n", cursize);

                char* new_buffer = (char*)realloc(buffer, cursize);
                if (new_buffer == NULL) {
                    fprintf(stderr, "could not reserve more memory\n");
                    break;
                }
                buffer = new_buffer;
                memset(buffer + lastsize, 0xff, cursize - lastsize);
            }
            else {
                printf("\n");
            }
            break;
        }
        else {
            if ((ipsaddr + offset) < 0) {
                printf("offset %c%lx cannot be applied to address %06x, ignoring\n",
                    offset < 0 ? '-' : '+', labs(offset), (uint32_t)ipsaddr);
            }
            ipsaddr += offset;
            ipssize = read16(ips);
            if (ipssize) {
                if (ipsaddr >= 0) {
                    /* regular chunk */
                    printf("std patch @%06x, size %04x\n", (uint32_t)ipsaddr, ipssize);
                    /* extend memory if needed + initialize it */
                    if ((static_cast<int32_t>(ipsaddr) + static_cast<int32_t>(ipssize)) > static_cast<int32_t>(cursize)) {
                        lastsize = cursize;
                        cursize = ipsaddr + ipssize;
                        char* new_buffer = (char*)realloc(buffer, cursize);
                        if (new_buffer == NULL) {
                            fprintf(stderr, "could not reserve more memory\n");
                            break;
                        }
                        buffer = new_buffer;
                        memset(buffer + lastsize, 0xff, cursize - lastsize);
                    }
                    fread(buffer + ipsaddr, ipssize, 1, ips);
                }
                else {
                    fseek(ips, ipssize, SEEK_CUR);
                }
            }
            else {
                /* RLE chunk */
                ipsrlen = read16(ips);
                if (ipsaddr >= 0) {
                    printf("RLE patch @%06x, size %04x\n", (uint32_t)ipsaddr, ipsrlen);
                    /* extend memory if needed + initialize it */
                    if ((ipsaddr + ipsrlen) > cursize) {
                        lastsize = cursize;
                        cursize = ipsaddr + ipsrlen;
                        char* new_buffer = (char*)realloc(buffer, cursize);
                        if (new_buffer == NULL) {
                            fprintf(stderr, "could not reserve more memory\n");
                            break;
                        }
                        buffer = new_buffer;
                        memset(buffer + lastsize, 0xff, cursize - lastsize);
                    }
                    memset(buffer + ipsaddr, fgetc(ips), ipsrlen);
                }
                else {
                    fgetc(ips);
                }
            }
        }
    }

    if (fopen_s(&fd, argv[3], "wb") != 0) {
        perror("cannot open output file");
        exit(1);
    }

    if (buffer != NULL) {
        fwrite(buffer, cursize, 1, fd);
    }
    else {
        fprintf(stderr, "Buffer is NULL, cannot write output file\n");
    }

    printf("done\n");
    fclose(ips);
    fclose(fd);
    free(buffer);
    return 0;
}