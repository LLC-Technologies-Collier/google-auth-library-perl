#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <openssl/evp.h>
#include <openssl/x509.h>
#include <openssl/x509v3.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <string.h>

static int generate_mock_cert(char **cert_pem_out, char **key_pem_out) {
    EVP_PKEY *pkey = NULL;
    EVP_PKEY_CTX *pctx = NULL;
    X509 *x509 = NULL;
    X509_NAME *name = NULL;
    BIO *cert_bio = NULL;
    BIO *key_bio = NULL;
    char *cert_pem = NULL;
    char *key_pem = NULL;
    long cert_len = 0;
    long key_len = 0;
    int ret = 0;

    pctx = EVP_PKEY_CTX_new_id(EVP_PKEY_RSA, NULL);
    if (!pctx) goto cleanup;
    if (EVP_PKEY_keygen_init(pctx) <= 0) goto cleanup;
    if (EVP_PKEY_CTX_set_rsa_keygen_bits(pctx, 2048) <= 0) goto cleanup;
    if (EVP_PKEY_keygen(pctx, &pkey) <= 0) goto cleanup;

    x509 = X509_new();
    if (!x509) goto cleanup;

    if (X509_set_version(x509, 2) <= 0) goto cleanup;

    if (ASN1_INTEGER_set(X509_get_serialNumber(x509), 1) <= 0) goto cleanup;

    if (!X509_gmtime_adj(X509_get_notBefore(x509), 0)) goto cleanup;
    if (!X509_gmtime_adj(X509_get_notAfter(x509), 31536000L)) goto cleanup;

    if (X509_set_pubkey(x509, pkey) <= 0) goto cleanup;

    name = X509_get_subject_name(x509);
    if (!name) goto cleanup;
    if (X509_NAME_add_entry_by_txt(name, "C", MBSTRING_ASC, (unsigned char*)"BE", -1, -1, 0) <= 0) goto cleanup;
    if (X509_NAME_add_entry_by_txt(name, "O", MBSTRING_ASC, (unsigned char*)"Test", -1, -1, 0) <= 0) goto cleanup;
    if (X509_NAME_add_entry_by_txt(name, "OU", MBSTRING_ASC, (unsigned char*)"Test", -1, -1, 0) <= 0) goto cleanup;
    if (X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, (unsigned char*)"Test", -1, -1, 0) <= 0) goto cleanup;
    if (X509_set_issuer_name(x509, name) <= 0) goto cleanup;

    if (X509_sign(x509, pkey, EVP_sha256()) <= 0) goto cleanup;

    key_bio = BIO_new(BIO_s_mem());
    if (!key_bio) goto cleanup;
    if (PEM_write_bio_PrivateKey(key_bio, pkey, NULL, NULL, 0, NULL, NULL) <= 0) goto cleanup;
    key_len = BIO_get_mem_data(key_bio, &key_pem);

    cert_bio = BIO_new(BIO_s_mem());
    if (!cert_bio) goto cleanup;
    if (PEM_write_bio_X509(cert_bio, x509) <= 0) goto cleanup;
    cert_len = BIO_get_mem_data(cert_bio, &cert_pem);

    *cert_pem_out = (char *)malloc(cert_len + 1);
    memcpy(*cert_pem_out, cert_pem, cert_len);
    (*cert_pem_out)[cert_len] = '\0';

    *key_pem_out = (char *)malloc(key_len + 1);
    memcpy(*key_pem_out, key_pem, key_len);
    (*key_pem_out)[key_len] = '\0';

    ret = 1;

cleanup:
    if (cert_bio) BIO_free(cert_bio);
    if (key_bio) BIO_free(key_bio);
    if (x509) X509_free(x509);
    if (pkey) EVP_PKEY_free(pkey);
    if (pctx) EVP_PKEY_CTX_free(pctx);
    return ret;
}

MODULE = Google::Auth   PACKAGE = Google::Auth

PROTOTYPES: ENABLE

SV *
generate_self_signed_cert()
    PREINIT:
        char *cert_pem = NULL;
        char *key_pem = NULL;
        HV *hv = NULL;
        SV *result = NULL;
    CODE:
        if (generate_mock_cert(&cert_pem, &key_pem)) {
            hv = newHV();
            hv_stores(hv, "cert", newSVpv(cert_pem, 0));
            hv_stores(hv, "key", newSVpv(key_pem, 0));
            result = newRV_noinc((SV *)hv);
            free(cert_pem);
            free(key_pem);
        } else {
            XSRETURN_UNDEF;
        }
        RETVAL = result;
    OUTPUT:
        RETVAL
