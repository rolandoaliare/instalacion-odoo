#!/usr/bin/env python3

from passlib.context import CryptContext

newpass = input('Ingrese Password: ')

setpw = CryptContext(schemes=['pbkdf2_sha512'])
encrypted_pass = setpw.hash(newpass.strip())

print(f'El hash es : {encrypted_pass}')

