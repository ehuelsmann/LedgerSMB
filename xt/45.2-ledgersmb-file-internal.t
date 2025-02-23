#!/usr/bin/perl

=head1 UNIT TESTS FOR LedgerSMB::File::Internal

Partial tests for the LedgerSMB::Internal module, which subclasses
LedgerSMB::File.

=cut


use Test2::V0;

use DBI;
use LedgerSMB::File::Internal;
use LedgerSMB::Magic qw(FC_INTERNAL);
use PGObject::Util::DBAdmin;

#######################################
# Create test run conditions
my $file;
my $result;
my @files;
my $test_db = "$ENV{LSMB_NEW_DB}_lsmb_file_test";

# Connect to base template database
my $dbh = DBI->connect(
    "dbi:Pg:dbname=$ENV{LSMB_NEW_DB}",
    undef,
    undef,
    { AutoCommit => 1, PrintError => 0 }
) or die "Can't connect to template database: " . DBI->errstr;

# Make a working copy of the template database
# We can't use a transation to make and rollback our changes as we
# need to test whether timestamps are updated between procedures.
# In a transaction, the timestamps will be identical.
$dbh->do(q{set client_min_messages = 'warning'});
$dbh->do("DROP DATABASE IF EXISTS $test_db");
$dbh->do("CREATE DATABASE $test_db WITH TEMPLATE $ENV{LSMB_NEW_DB}")
    or die "Failed to create new database $test_db for tests" . DBI->errstr;

# Connect to the new working copy
$dbh = DBI->connect(
    "dbi:Pg:dbname=$test_db",
    undef,
    undef,
    { AutoCommit => 1, PrintError => 0 }
) or die "Can't connect to working database: " . DBI->errstr;
$dbh->{private_LedgerSMB} = { schema => 'xyz' };
$dbh->do(q{set search_path=xyz})
    or die "Can't set search path: " . $dbh->errstr;;

# Include plain text files in file output for invoice templates
$dbh->do("UPDATE mime_type SET invoice_include = TRUE WHERE mime_type='text/plain'")
    or die "Can't set mime type for inclusion on invoices";


#
#######################################


# Test that error is generated when storing a file without a valid lsmb user
$file = LedgerSMB::File::Internal->new(
    _dbh => $dbh,
    content => 'This is the file content',
    file_name => 'test_file.txt',
    description => 'This is the file description',
);
#TODO This test fails because of an SQL bug
#ok(!$file, 'error raised trying to store file without valid LedgerSMB user');


# Set up database environment for tests with valid LedgerSMB user
$dbh->do("
    INSERT INTO entity(
        name,
        control_code,
        country_id
    ) VALUES (
        'LSMB-FILE-TEST',
        'LSMB-FILE-TEST',
        1  -- Ascension Island
    )
") or die "Failed to insert test entity: " . DBI->errstr;

$dbh->do("
    INSERT INTO users(
        username,
        entity_id
    )
    SELECT SESSION_USER, id FROM entity
    WHERE name = 'LSMB-FILE-TEST'
") or die "Failed to insert test user: " . DBI->errstr;


# Store a new 'internal' file
$file = LedgerSMB::File::Internal->new(
    _dbh => $dbh,
    content => 'This is the file content',
    file_name => 'test_file.txt',
    description => 'This is the file description',
);
ok($file, 'LedgerSMB::File::Internal object created');
is($file->get_mime_type(), 'text/plain', 'MIME type set based on file extension');
ok(defined($file->mime_type_id), 'MIME type id is defined');

ok lives { $result = $file->attach; }, 'File saved successfully';
ok($result && ref $result, 'stored new file');
is($result->{file_name}, 'test_file.txt', 'file name set correctly for new file');
is($result->{description}, 'This is the file description', 'description name set correctly for new file');
like($result->{id}, qr/^\d+$/, 'id is numeric for new file');
like($result->{uploaded_by}, qr/^\d+$/, 'uploaded_by is numeric for new file');
like($result->{uploaded_at}, qr/^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d$/, 'uploaded_at is correct format for new file');


# Overwrite an existing 'internal' file
my $old_result = $result;
$file = LedgerSMB::File::Internal->new(
    _dbh => $dbh,
    content => 'New file content',
    file_name => 'test_file.txt',
    description => 'New description',
);
ok($file, 'LedgerSMB::File::Internal object created');

ok( lives { $result = $file->attach; }, 'File saved successfully' )
    or diag $dbh->errstr;
ok($result && ref $result, 'overwritten an existing file');

#TODO These tests are broken because of an SQL bug - nothing is returned after an update
#is($result->{file_name}, 'test_file.txt', 'file name set correctly when overwriting file');
#is($result->{description}, 'New description', 'description name set correctly when overwriting file');
#is(${$result->{content}}, 'New file content', 'file content set correctly when overwriting file');
#is($result->{mime_type_id}, 153, 'mime_type_id represents text/plain when overwriting file');
#is($result->{id}, $old_result->{id}, 'id remains the same when overwriting file');
#like($result->{uploaded_by}, qr/^\d+$/, 'uploaded_by is numeric for new file');
#like($result->{uploaded_at}, qr/^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d$/, 'uploaded_at is correct format when overwriting file');
#isnt($result->{uploaded_at}, $old_result->{uploaded_at}, 'uploaded_at changes when overwriting file');


# Retrieve the file
$file = LedgerSMB::File::Internal->new(
    _dbh => $dbh,
    id => $old_result->{id},
);
ok lives { $file->get; }, 'File retrieval without errors; id=' . $old_result->{id};
is($file->{file_name}, 'test_file.txt', 'file_name correct when retrieving file');
is($file->{description}, 'New description', 'description correct when retrieving file');
is(${$file->{content}}, 'New file content', 'file content correct when retrieving file');
is($file->{mime_type_id}, 153, 'mime_type_id represents text/plain when retrieving file');
is($file->{id}, $old_result->{id}, 'correct id when retrieving file');
is($file->{uploaded_by}, $old_result->{uploaded_by}, 'correct uploaded_by when retrieving file');
like($file->{uploaded_at}, qr/^\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d$/, 'uploaded_at is correct format when retrieving file');
isnt($file->{uploaded_at}, $old_result->{uploaded_at}, 'uploaded_at has been changed by overwriting file');
is($file->{file_path}, undef, 'file_path is undef when retrieving file');
is($file->{reference}, undef, 'reference is undef when retrieving file');
is($file->{src_class}, undef, 'src_class is undef when retrieving file');

#TODO - These tests fail because the properties are not set, but are expected to pass
#is($file->{mime_type_text}, 'text/plain', 'mime_type_text set correctly when retrieving file');
#is($file->{uploaded_by_name}, 'LSMB-FILE-TEST', 'correct uploaded_by_name when retrieving file');


# Add another file of type 'text/x-uri'
# This isn't really a file, but the file storage mechanism is coerced
# to store uris, which are then given special treatment by retrieval methods
my $uri = LedgerSMB::File::Internal->new(
    _dbh => $dbh,
    uri => 'https://ledgersmb.org',
    file_name => 'i-am-a-uri',  # cannot be null, must be unique, though it has no meaning for uri
    description => 'Link description',
);
ok($uri, 'LedgerSMB::File::Internal object created for uri');
ok lives { $uri = $uri->attach; }, 'Successfully attached URI'
    or diag $@; 
ok( $uri, 'attached uri');

# List files
@files = $file->list({
});
is(scalar(@files), 2, 'list method returned correct number of files');

# Check results for uri. Content should be set
# Return order is not deterministic, so find the uri text file record to test
$result = $files[0]->{file_name} eq 'test_file.txt' ? $files[1] : $files[0]; # URIs don't have mime types

# Can't use is_deeply() as it won't handle content reference,
# so test each key/value separately
is(scalar(keys %{$result}), 7, 'list() result for uri has correct number of hash keys')
    or diag join(' ', keys %{$result});
is($result->{id}, $uri->{id}, 'file list id is correct for uri');
is($result->{uploaded_by_id}, $uri->{uploaded_by}, 'file list uploaded_by_id is correct for uri');
is($result->{uploaded_by_name}, 'LSMB-FILE-TEST', 'file list uploaded_by_name is correct for uri');
is($result->{file_name}, 'i-am-a-uri', 'file list file_name is correct for uri');
is($result->{description}, 'Link description', 'file list description is correct for uri');
is($result->{uri}, 'https://ledgersmb.org', 'file list content is defined correctly for uri');
is($result->{uploaded_at}, $uri->{uploaded_at}, 'file list uploaded_at is correct for uri');

# Check results for 'normal' file. Content should be undef
# Return order is not deterministic, so find the plain text file record to test
$result = $files[0]->{file_name} eq 'test_file.txt' ? $files[0] : $files[1];

# Can't use is_deeply() as it won't handle content reference,
# so test each key/value separately.
is(scalar(keys %{$result}), 7, 'list() result for file has correct number of hash keys');
is($result->{id}, $file->{id}, 'file list id is correct for file');
is($result->{uploaded_by_id}, $file->{uploaded_by}, 'file list uploaded_by_id is correct for file');
is($result->{uploaded_by_name}, 'LSMB-FILE-TEST', 'file list uploaded_by_name is correct for file');
is($result->{file_name}, 'test_file.txt', 'file list file_name is correct for file');
is($result->{description}, 'New description', 'file list description is correct for file');
is(${$result->{content}}, undef, 'file list content is undef for file');
is($result->{uploaded_at}, $file->{uploaded_at}, 'file list uploaded_at is correct for file');



# Drop our working database
$dbh->disconnect;
$dbh = DBI->connect(
    "dbi:Pg:dbname=$ENV{LSMB_NEW_DB}",
    undef,
    undef,
    { AutoCommit => 1, PrintError => 0 }
) or die "Can't reconnect to template database: " . DBI->errstr;

$dbh->do("DROP DATABASE $test_db")
    or die "Can't drop test database: " . DBI->errstr;

done_testing;
