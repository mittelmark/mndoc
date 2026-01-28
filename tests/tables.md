---
title: "Long Title"
author: MicroEmacs User
date: 2026-01-28 07:33:23
abstract: >
    Some abstract ...
    on several lines...
---

## Some example tables

### no leading pipes

tab  | col 1  | col 2 
-----|--------|-------
row1 | val1.1 | val1.2
row2 | val2.1 | val2.2
row3 | val3.1 | val3.2


### leading pipes

| tab  | col 1  | col 2 
|------|--------|-------
| row1 | val1.1 | val1.2
| row2 | val2.1 | val2.2
| row3 | val3.1 | val3.2

## protected pipes in text

This is a text which should contain a pipe, so here it is `|`:
we can as well do two pipes like this `||`. They should be visible as pipes.

## unprotected pipes in text

Unprotected pipes like this | should create some stupid table.

## EOF

