package LedgerSMB::Routes::ERP::API::Invoices;

=head1 NAME

LedgerSMB::Routes::ERP::API::Invoices - Webservice routes for invoices

=head1 DESCRIPTION

Webservice routes for invoices

=head1 SYNOPSIS

  use LedgerSMB::Routes::ERP::API::Invoices;

=head1 METHODS

This module doesn't export any methods.

=cut

use strict;
use warnings;

use HTTP::Status qw( HTTP_OK HTTP_FOUND
    HTTP_BAD_REQUEST HTTP_UNSUPPORTED_MEDIA_TYPE );
use Plack::Request::WithEncoding;
use List::Util qw( reduce );
use Scalar::Util qw( blessed reftype );


use LedgerSMB::Company;
use LedgerSMB::Entity::Credit_Account;
use LedgerSMB::Magic qw( EC_CUSTOMER EC_VENDOR );
use LedgerSMB::Part;

use LedgerSMB::Router appname => 'erp/api';

set logger => 'erp.api.invoices';


get '/invoices/' => sub {
};

get '/invoices/:id' => sub {
    my ($env) = @_;
    my $r = Plack::Request::WithEncoding->new($env);

};

patch '/invoices/:id' => sub {

};



=pod comment

{
    eca: {
       # when listing the number, we also need the type (customer/vendor)...
       "type": "customer",
       "number": "...",
       "id": "...",
       "entity": {
          "credit_limit": {
             "total": 1000.00,
             "used": 300.00,
             "available": 700.00,
          },
          ...
       },
    },
   "ship-to": {
      ###TODO: come up with a way to select a "ship-to"
      ...
    },
    "account": {
       "accno": "1203",
       "description": "Accounts receivable 01",
    },
    "currency": "USD",
    "description": "...",
    "notes": "...",
    "internal-notes": "...",
    "shipping-point": "...",
    "ship-via": "...",
    "invoice-number": "INV-00001",
    "order-number": "ORD-000010",
    "po-number": "CUST-1001100",
    "dates": {
       "due": "2021-01-01", (iso format)
       "created": "2021-01-01",
       "book": "2021-01-01",
       // "value": "...?",
    },
    "lines_total": 15.00,
    "taxes_total": 3.00,
    "total": 18.00,
    "paid": 5.00,
    "due": 13.00,
    "payments": [
       {
         "date": "2021-01-02",
         "source": "...",
         "memo": "...",
         "amount": 2.50,
         "account": {
            "accno": "1060",
            "description": "Checking account",
         },
       },
       ...
    ],
    "lines": [
       {
         "item": 1,
         "part": {
            "number": "MH-1-H",
            "description": "Description of part",
            "unit": "hour",
            "price": 145.5,
            "discount": 8.5,
            "discount_type": "%"
          },
         "description": "overruled description (not in the resource unless set--while the resource is in SAVED state; filled when POSTED)",
         "price": "overruled price (not in the resource unless explicitly set--while the resource is in SAVED state; filled when POSTED)",
         "unit": "overruled unit (not in the resource unless explicitly set--while the resource is in SAVED state; filled when POSTED)",
         "qty": 1.5,
         "discount": 10,
         "discount_type": "%",
         "taxform": 0,
         "delivery_date": "",
         "note": "",
         "serialnumber": "",
         "group": null
       },
       ...
    ],
    "taxes": {
      "2215": {
        "tax": {
           "category": "2215", # for now, presents the accno of the tax account
           "name": "Washington Sales Tax",
           "rate": 0.13, # (13%) ; rate on dates->book, or current rate if that's null
        },
        "base-amount": 2.00,
        "calculated-amount": 0.26,
        "amount": null,
        "source": "some external reference",
        "memo": "some remarks to be retained"
      },
      ...
    ]
}

=cut


post '/invoices/' => sub {
    my ($env) = @_;
    my $r = Plack::Request::WithEncoding->new($env);
    my $c = LedgerSMB::Company->new(dbh => $env->{'lsmb.db'});

    {
        my $ct = $r->headers->content_type;
        unless ($ct eq 'application/json') {
            return error(
                $r,
                HTTP_UNSUPPORTED_MEDIA_TYPE,
                {
                    msg     => 'Unexpected Content-Type header',
                    details => "Content-Type value '$ct' provided, but 'application/json expected"
                });
        }
    }
    my $body = json()->decode($r->content);
    my @errors;

    foreach my $req (qw( eca account )) {
        if (not exists $body->{$req}
            or not defined $body->{$req}) {
            push @errors, {
                msg => "Missing key '$req'",
            };
        }
    }

    my $inv = {};
    # lookup the required fields: eca
    if (reftype $body->{eca} eq 'HASH') {
        my %map = ( 'customer' => EC_CUSTOMER(),
                    'vendor' => EC_VENDOR());
        my $eca = LedgerSMB::Entity::Credit_Account->new(
            _dbh => $env->{'lsmb.db'},
            entity_class => $map{$body->{eca}->{type}},
            );
        if (defined $body->{eca}->{id}
            and $body->{eca}->{id} ne '') {
            $inv->{eca} = $eca->get_by_id($body->{eca}->{id});
        }
        elsif (defined $body->{eca}->{number}
               and $body->{eca}->{number} ne '') {
            if (defined $body->{eca}->{type}
                and exists $map{$body->{eca}->{type}}) {
                $inv->{eca} = $eca->get_by_meta_number(
                    $body->{eca}->{number},
                    $map{$body->{eca}->{type}},
                    );
            }
            else {
                push @errors, {
                    msg => q|Expecting either 'customer' or 'vendor' in key 'eca.number'; found| . $body->{eca}->{number},
                };
            }
        }
        else {
            push @errors, {
                msg => q|Expecting 'eca' object to hold either an 'id' key or 'number'+'type' keys|,
            };
        }

        unless ($inv->{eca}) {
            push @errors, {
                msg => q|Specified customer/vendor not found|,
            };
        }
    }
    else {
        push @errors, {
            msg => q|Expecting toplevel 'eca' key with object value specifying the customer/vendor|,
        };
    }

    ###TODO: process required values 'currency', ...


    # look up the AR/AP account by accno
    if (exists $body->{account}
        and defined $body->{account}
        and reftype $body->{account} eq 'HASH'
        and defined $body->{account}->{accno}
        and $body->{account}->{accno} ne '') {
        my $account = $c->configuration->coa_nodes
            ->get(by => (accno => $body->{account}->{accno}));
        if (blessed $account) {
            $inv->{account} = $account;
        }
        else {
            push @errors, {
                msg => qq|Specified account ($body->{account}->{accno}) not found|,
            };
        }
    }
    else {
        push @errors, {
            msg => q|Expecting toplevel 'account' key with object value specifying the receivables/payables account|,
        };
    }

    # set the optional fields
    foreach my $field (qw( currency description notes internal-notes
                       invoice-number order-number po-number ship-via
                       shipping-point )) {
        if (exists $body->{$field}
            and defined $body->{$field}
            and $body->{$field} ne '') {
            $inv->{$field} = $body->{$field};
        }
    }

    # process optional nested fields
    if (exists $body->{'ship-to'}
        and defined $body->{'ship-to'}) {
        if (reftype $body->{'ship-to'} eq 'HASH') {
            ...;
        }
        else {
            push @errors, {
                msg => q|Expecting toplevel 'ship-to' key with object value specifying a shipping address|,
            };
        }
    }

    if (exists $body->{dates}
        and defined $body->{dates}) {
        if (reftype $body->{dates} eq 'HASH') {
            my %map = ('due'     => 'duedate',
                       'book'    => 'transdate',
                       'created' => 'crdate');
            foreach my $d (qw( due book created )) {
                # due|created|book
                next if not $body->{dates}->{$d};
                if ($body->{dates}->{$d} =~ m/^\d{4,4}-\d\d-\d\d$/) {
                    $inv->{$map{$d}} = $body->{dates}->{$d};
                }
                else {
                    push @errors, {
                        msg => qq|Incorrect date format for key dates.$d; expecting 'YYYY-MM-DD', found $body->{dates}->{$d}|,
                    };
                }
            }
        }
        else {
            push @errors, {
                msg => q|Expecting toplevel 'dates' key with object value specifying invoice related dates 'created'/'book'/'due'|,
            };
        }
    }

    if (exists $body->{lines}
        and defined $body->{lines}) {
        if (reftype $body->{lines} eq 'ARRAY') {
            my @lines;
            $inv->{lines} = \@lines;
            for my $line ($body->{lines}->@*) {
                # set the optional fields
                my $inv_line = {};
                push @lines, $inv_line;

                foreach my $field (qw( description price unit qty discount
                                   discount_type taxform delivery_date note
                                   serialnumber group )) {
                    if (exists $line->{$field}
                        and defined $line->{$field}
                        and $line->{$field} ne '') {
                        $inv_line->{$field} = $line->{$field};
                    }
                }
                if (defined $inv_line->{qty}) {
                    if ($inv_line->{qty} !~ m/^\d+([.]\d+)$/) {
                        push @errors, {
                            msg => q|Non-numeric data in 'qty' field|,
                            val => $inv_line->{qty},
                        };
                    }
                }
                else {
                    $inv_line->{qty} = 1;
                }
                if (defined $inv_line->{price}) {
                    if ($inv_line->{price} !~ m/^\d+([.]\d+)$/) {
                        push @errors, {
                            msg => q|Non-numeric data in 'price' field|,
                            val => $inv_line->{price},
                        };
                    }
                }
                if (defined $inv_line->{discount}) {
                    if ($inv_line->{discount} !~ m/^\d+([.]\d+)$/) {
                        push @errors, {
                            msg => q|Non-numeric data in 'discount' field|,
                            val => $inv_line->{discount},
                        };
                    }
                }
                if (defined $inv_line->{discount_type}) {
                    if ($inv_line->{discount_type} !~ m/^(%)$/) {
                        push @errors, {
                            msg => q|Unexpected value in 'discount_type' field; expected '%'|,
                            val => $inv_line->{discount_type},
                        };
                    }
                }
                if (defined $inv_line->{delivery_date}) {
                    if ($inv_line->{delivery_date} !~  m/^\d{4,4}-\d\d-\d\d$/) {
                        push @errors, {
                            msg => q|Non-date value in 'delivery_date' field|,
                            val => $inv_line->{delivery_date},
                        };
                    }
                }
                if (exists $line->{part}
                    and defined $line->{part}) {
                    if (reftype $line->{part} eq 'HASH') {
                        if (exists $line->{part}->{number}
                            and defined $line->{part}->{number}
                            and $line->{part}->{number} ne '') {
                            my $part = LedgerSMB::Part->new(
                                _dbh => $env->{'lsmb.db'}
                                );
                            $inv_line->{part} = $part->get_by_partnumber(
                                $line->{part}->{number}
                                );
                            unless ($inv_line->{part}->{id}) {
                                push @errors, {
                                    msg => q|Specified part not found|,
                                    val => $line->{part}->{number},
                                };
                            }
                            # "lastcost" is the price to put on
                            # a vendor invoice, whereas "sellprice" goes
                            # into the sales invoice....
                            # Map either into the 'price' field, so we
                            # can have unified handling from here.
                            if ($inv->{eca}->entity_class == EC_CUSTOMER()) {
                                $inv_line->{part}->{price} =
                                    delete $inv_line->{part}->{sellprice};
                            }
                            else {
                                $inv_line->{part}->{price} =
                                    delete $inv_line->{part}->{lastcost};
                            }
                        }
                        else {
                            push @errors, {
                                msg => q|Line fails to specify part number in 'number' key of the 'part' object|,
                                val => $line,
                            };
                        }
                    }
                    else {
                        push @errors, {
                            msg => q|Unexpected type for 'part' key; object expected|,
                            val => $line,
                        };
                    }
                }
            }
        }
        else {
            push @errors, {
                msg => q|Expected toplevel key 'lines' with array value|,
            }
        }
    }

    if (exists $body->{payments}
        and defined $body->{payments}) {
        if (reftype $body->{payments} eq 'ARRAY') {
            my @payments;
            $inv->{payments} = \@payments;
            foreach my $payment ($body->{payments}->@*) {
                my $inv_payment = {};
                push @payments, $inv_payment;

                foreach my $field (qw( date source memo amount )) {
                    if (exists $payment->{$field}
                        and defined $payment->{$field}
                        and $payment->{$field} ne '') {
                        $inv_payment->{$field} = $payment->{$field};
                    }
                }

                if (exists $payment->{account}
                    and defined $payment->{account}) {
                    if (reftype $payment->{account} eq 'HASH') {
                        if (exists $payment->{account}->{accno}
                            and defined $payment->{account}->{accno}
                            and $payment->{account}->{accno} ne '') {

                            ###TODO: Payment account lookup
                            ...;
                            my $account = $c->configuration->coa_nodes
                                ->get(by => (accno => $payment->{account}->{accno}));
                            $inv_payment->{account} = $account;
                            unless (blessed $account) {
                                push @errors, {
                                    msg => 'Payment account not found',
                                    val => $payment->{account}->{accno},
                                };
                            }
                        }
                        else {
                            push @errors, {
                                msg => q|Expected (non-empty) 'account.accno' key in payment line|,
                                val => $payment,
                            };
                        }
                    }
                    else {
                        push @errors, {
                            msg => q|Expected 'account' key with object value in payment line|,
                            val => $payment,
                        };
                    }
                }
            }
        }
        else {
            push @errors, {
                msg => q|Expected toplevel key 'payments' with array value|,
            }
        }
    }

    if (exists $body->{taxes}
        and defined $body->{taxes}) {
        if (reftype $body->{taxes} eq 'HASH') {
            my %taxes;
            $inv->{taxes} = \%taxes;
            foreach my $tax (values $body->{taxes}->%*) {
                if (exists $taxes{$tax->{number}}) {
                    push @errors, {
                        msg => q|Expecting each tax(number) to be specified exactly once; second or later occurrance found|,
                        val => $tax,
                    };
                }
                else {
                    my $inv_tax = {};
                    $taxes{$tax->{number}} = $inv_tax;

                    foreach my $field (qw(base-amount amount source memo
                                       calculated-amount)) {
                        if (exists $tax->{$field}
                            and defined $tax->{$field}
                            and $tax->{$field} ne '') {
                            $inv_tax->{$field} = $tax->{$field};
                        }
                    }
                    if (exists $tax->{tax}
                        and defined $tax->{tax}) {
                        if (reftype $tax->{tax} eq 'HASH') {
                            if (exists $tax->{tax}->{category}
                                and defined $tax->{tax}->{category}
                                and $tax->{tax}->{category} ne '') {
                                ...; # look up the payment account and insert here
                                # also note: a tax needs to be enabled for the
                                # customer/vendor!
                                #
                                ###TODO: the code below does not do this check!
                                my $sth = $env->{'lsmb.db'}->prepare(
                                    q|
   SELECT a.accno as category, a.description, t.rate
     FROM account a JOIN tax t ON t.chart_id = a.id
    WHERE a.accno = ?
     AND coalesce(validto::timestamp, 'infinity')
             >= coalesce(?::timestamp, now())
   ORDER BY validto ASC
   LIMIT 1
                                    |
                                    )
                                    or die $env->{'lsmb.db'}->errstr;
                                $sth->execute($tax->{tax}->{category},
                                              $inv->{transdate})
                                    or die $sth->errstr;
                                $inv_tax->{tax} = $sth->fetchrow_hashref;
                                die $sth->errstr
                                    if $sth->err;

                                unless ($inv_tax->{tax}) {
                                    push @errors, {
                                        msg => q|Tax category not found for given transaction date|,
                                        val => {
                                            tax       => $tax->{tax},
                                            transdate => $inv->{transdate},
                                        },
                                    };
                                }
                            }
                            else {
                                push @errors, {
                                    msg => q|Expected (non-empty) 'category' key in tax specification|,
                                    val => $tax->{tax},
                                };
                            }
                        }
                    }
                    else {
                        push @errors, {
                            msg => q|Expected 'tax' key with object value specifying tax category|,
                            val => $tax,
                        };
                    }
                }
            }
        }
        else {
            push @errors, {
                msg => q|Unexpected type for toplevel key 'taxes'; object value expected|,
            };
        }
    }

    return error($r, HTTP_BAD_REQUEST, [], @errors)
        if scalar(@errors) > 0;

    #### So, we're now without errors, so lets start the required calculations

    #  1. Totalize the quantities on the rows per part
    #  2. Run the price matrix over the resulting parts counts
    #  3. Apply the resulting pricing on the lines by their parts
    #  4. Calculate the line totals based on price-matrix outcome
    #  5. Apply 'business type', 'price matrix' and 'line' discounts per line
    #  6. Determine the applicable tax types and rates per line
    #  7. Calculate the totals per tax rate over the lines
    #  8. Apply the tax rate to the rate total
    #  9. Calculate the totals of the lines and taxes

    my %part_qty;
    for my $line ($inv->{lines}->@*) {

        # Don't take the quantity into account when the price has been overruled
        next if exists $line->{price};

        # $line->{part} contains the looked-up data; not the submitted data
        $part_qty{$line->{part}->{id}} = 0
            unless exists $part_qty{$line->{part}->{id}};

        $part_qty{$line->{part}->{id}} += $line->{qty};
    }

    if (keys %part_qty) {
        my $sth;

        if ($inv->{eca}->entity_class == EC_CUSTOMER()) {
            $sth = $env->{'lsmb.db'}->prepare(
                q|
                SELECT * FROM pricematrix__for_customer(?, ?, ?, ?, ?)
                |
                )
                or die $env->{'lsmb.db'}->errstr;
        }
        else { # vendor
            $sth = $env->{'lsmb.db'}->prepare(
                q|
                SELECT * FROM pricematrix__for_vendor(?, ?)
                |
                )
                or die $env->{'lsmb.db'}->errstr;
        }
        for my $part_id (keys %part_qty) {
            if ($inv->{eca}->entity_class == EC_CUSTOMER()) {
                $sth->execute($inv->{eca}->{entity_id},
                              $part_id, $inv->{transdate},
                              $part_qty{$part_id},
                              $inv->{currency})
                    or die $sth->errstr;
            }
            else {
                $sth->execute($inv->{eca}->{entity_id}, $part_id)
                    or die $sth->errstr;
            }

            my $ref = $sth->fetchrow_hashref('NAME_lc');
            # an empty ref means either an error, or no results...
            if (not $ref and $sth->err) {
                die $sth->errstr;
            }
            else {
                # apply the price matrix to the rows in the invoice

                for my $line (grep { not exists $_->{price}
                                     and $_->{part}->{id} eq $part_id }
                              $inv->{lines}->@*) {
                    ###TODO: Round price due to price matrix?
                    # Note: when we do, we need to round to the same number
                    # of digits as the precision in the database.
                    $line->{part}->{price} =
                        ( 1 - ($ref->{pricebreak} // 0)/100 )
                        * ($ref->{sellprice}               # customer
                           // $ref->{lastcost}             # vendor
                           // $line->{part}->{price});     # part's default
                }
            }
        }
    }

    for my $line ($inv->{lines}->@*) {
        my $total = $line->{qty} * ($line->{price} // $line->{sellprice});

        if ($line->{discount_type}) {
            if ($line->{discount_type} eq '%') {
                $total *= (1 - $line->{discount}/100);
            }
            else {
                # This should not be reachable:
                #  We verified allowed values above
                die 'Unexpected value for "discount_type"';
            }
        }
        ###BUG: we need rounding and accessing LedgerSMB::Company_Config
        # is a no-no due to its global state. We need access to the company
        # settings from the $env somehow
        $line->{total} =
            LedgerSMB::PGNumber->new($total)->bfround(
                -$LedgerSMB::Company_Config::settings{decimal_places}
            );
    }
    $inv->{lines_total} = reduce { $a + $b->{total} } 0, $inv->{lines}->@*;

    my $sth = $env->{'lsmb.db'}->prepare(
        q|
        WITH taxes AS (
          SELECT *,
                 LAG(validto) OVER (PARTITION BY tax.chart_id
                                    ORDER BY validto ASC NULLS LAST) as validfrom
            FROM tax
        )
        SELECT *
          FROM taxes
          JOIN account ON account.id = taxes.chart_id
          JOIN eca_tax et ON et.chart_id = account.id
          JOIN taxmodule tm ON taxes.taxmodule_id = tm.taxmodule_id
         WHERE et.eca_id = ?
               AND (validfrom IS NULL OR ? > validfrom)
               AND (validto IS NULL OR ? <= validto)
        |)
        or die $env->{'lsmb.db'}->errstr;
    $sth->execute($inv->{eca}->{id},
                  $inv->{transdate},
                  $inv->{transdate})
        or die $sth->errstr;
    $inv->{taxes} = $sth->fetchall_hashref('accno');
    die $sth->errstr
        if $sth->err;
    if (keys $inv->{taxes}->%* and keys %part_qty) {
        my %part_tax;
        $sth = $env->{'lsmb.db'}->prepare(
            q|
            SELECT *
              FROM partstax pt
              JOIN accounts a ON pt.chart_id = a.id
             WHERE pt.id = ?
            |)
            or die $env->{'lsmb.db'}->errstr;
        for my $part_id (keys %part_qty) {
            $sth->execute($part_id)
                or die $sth->errstr;

            my $ref = $sth->fetchall_hashref('accno');
            die $sth->errstr
                if $sth->err;
            for my $taxno (keys $inv->{taxes}->%*) {
                if (exists $ref->{$taxno}) {
                    $part_tax{$part_id}->{$taxno} = $ref->{$taxno};
                }
            }
        }


        for my $line ($inv->{lines}->@*) {
            next unless exists $part_tax{$line->{part}->{id}};

            my @taxes =
                sort {
                    $a->{pass} <=> $b->{pass}
            } values $part_tax{$line->{part}->{id}}->%*;
            ###BUG: this creates built-in the "Tax::Simple" module;
            # it also does not support tax extraction
            # apparently, there was originally a reason to support more
            # complex Tax modules...
            ###BUG: this does not support minvalue and maxvalue taxes yet

            my $base = $line->{total};
            my $passtax = 0;
            my $pass = 0;
            for my $tax (@taxes) {
                if ($pass != $tax->{pass}) {
                    $base += $passtax;
                    $passtax = 0;
                    $pass = $tax->{pass};
                }

                my $amount = $base*$tax->{rate};
                $line->{taxes}->{$tax->{accno}} = {
                    base   => $base,
                    rate   => $tax->{rate},
                    amount => $amount,
                };
                $inv->{taxes}->{$tax->{accno}}->{base}   += $base;
                $inv->{taxes}->{$tax->{accno}}->{amount} += $amount;
            }
        }
    }
    ###BUG: These amounts in don't have these names in the invoice resource!!!
    $inv->{netamount} = $inv->{amount} - ( $inv->{taxes_total} // 0);
    ###TODO: Where do we apply the type-of-business-based discount???


    ###TODO: create and save the invoice; optionally followed by posting it
    ###TODO: Add multi-currency support
    $inv->{amount_tc}    = $inv->{amount};
    $inv->{netamount_tc} = $inv->{netamount};

    ###BUG: Assert that the invoice is posted in functional currency
    ###BUG: Assert that taxincluded is false/not supplied

    $sth = $env->{'lsmb.db'}->prepare(
        # What to do with 'setting_sequence' (for 'ar')?
        q|
        INSERT INTO ar (invoice, approved,
            invnumber, ordnumber, quonumber, ponumber,
            amount_bc, netamount_bc, curr, amount_tc, netamount_tc, taxincluded,
            transdate, crdate, duedate,
            description, notes, intnotes,
            shippingpoint, shipvia,
            person_id, language_code,
            entity_credit_account
            )
        VALUES ('t'::boolean, 'f'::boolean,
                 ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                 ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        RETURNING id
        |)
        or die $env->{'lsmb.db'}->errstr;
    $sth->execute(
        ( map { $inv->{$_} }
          qw/ invnumber ordnumber quonumber ponumber
              amount netamount curr amount_tc netamount_tc taxincluded
              transdate crdate duedate
              description notes intnotes
              shippingpoint shipvia
              person_id language_code
          / ),
        $inv->{eca}->{id}
        )
        or die $sth->errstr;
    my ($inv_id) = $sth->fetchrow_array;
    die $sth->errstr
        if $sth->err;

    $sth = $env->{'lsmb.db'}->prepare(
        q|
        INSERT INTO invoice (trans_id, parts_id,
              description, qty, sellprice, precision, fxsellprice,
              discount, unit, deliverydate, serialnumber, vendor_sku, notes)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        RETURNING id
        |)
        or die $env->{'lsmb.db'}->errstr;
    my $asth = $env->{'lsmb.db'}->prepare(
        q|
        INSERT INTO acc_trans (approved, trans_id, invoice_id, chart_id,
              amount_bc, amount_tc, curr, transdate )
          VALUES ('f'::boolean, ?, ?, ?,
                  ?, ?, ?, ?)
        RETURNING entry_id
        |)
        or die $env->{'lsmb.db'}->errstr;

    my $sign = ($inv->{eca}->entity_class == EC_CUSTOMER()) ? -1 : 1;
    ###BUG: check signs!!!
    $asth->execute($inv_id, undef, # no associated invoice line
                   ($inv->{account}->{id} =~ s/^A-//r),
                   $sign*$inv->{total}, $sign*$inv->{total},
                   (map { $inv->{$_} } qw/currency transdate/)
        )
        or die $asth->errstr();
    for my $line ($inv->{lines}->@*) {
        ###TODO: This account determination only applies to services????
        my $account_id =
            (($inv->{eca}->entity_class == EC_CUSTOMER())
             ? $line->{part}->{income_accno_id}
             : $line->{part}->{expense_accno_id});

        # generate line in 'invoice' table
        ###TODO: extract the precision from the 'price'
        ###BUG: check signs!!!
        $sth->execute(
            $inv_id, $line->{part}->{id}, $line->{description}, $line->{qty},
            $line->{price}, 0, $line->{price}, ###TODO: single currency
            (map { $line->{$_} }
             qw/discount unit deliverydate serialnumber vendor_sku notes/)
            )
            or die $sth->errstr;
        my ($invline_id) = $sth->fetchrow_array;
        die $sth->errstr
            if $sth->err;

        ###BUG: check signs!!!
        $asth->execute($inv_id, $invline_id, $account_id,
                       -$sign*$line->{total}, -$sign*$line->{total},
                       $inv->{currency}, $inv->{transdate}
            )
            or die $asth->errstr;
    }

    $sth = $env->{'lsmb.db'}->prepare(
        q|
        INSERT INTO tax_extended (tax_basis, rate, entry_id)
        VALUES (?, ?, ?)
        |)
        or die $env->{'lsmb.db'}->errstr;
    for my $tax (values $inv->{taxes}->%*) {
        $asth->execute($inv_id, undef, $tax->{some_BUG_account_id},
                       -$sign*$tax->{amount}, -$sign*$tax->{amount},
                       $inv->{currency}, $inv->{transdate})
            or die $asth->errstr;

        my ($entry_id) = $asth->fetchrow_array;
        die $asth->errstr
            if $asth->err;

        $sth->execute($tax->{amount}, $tax->{rate}, $entry_id)
            or die $sth->errstr;
    }

    return [
        HTTP_FOUND,
        [ 'Location' => "./$inv_id" ],
        [  ] ];
};



=head1 LICENSE AND COPYRIGHT

Copyright (C) 2021 The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut


1;
