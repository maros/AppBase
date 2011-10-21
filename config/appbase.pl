return {
    Catalyst    => {
        name            => 'AppBase',
        app_name        => 'AppBase',
        default_view    => 'TT',
    },
    
    Database    => {
        main        => {
            dsn             => 'dbi:Pg:dbname=appbase',
            user            => 'maros',
            password        => 'ononales54',
            pg_enable_utf8  => 1,
            on_connect_do   => [
              'SET search_path=appbase',
            ],
        }
    },
    
    Login       => {
        providers   => {
            password    => {},
            remote      => {
                service     => ['google','openid'],
            },
            
        },
    },
    
    I18N        => {
        default_locale     => 'en',
        locales            => {
            'en'               => {},
        }
    },
    
    'Model::Maketext' => {
        class           => 'AppBase::Maketext',
    },
#
#    'static' => {
#        debug          => 0,
#        logging        => 0,
#        dirs           => [qw/static/],
#    },
#    
#    session => {
#        flash_to_stash => 1,
#        expires        => (10 * 60 * 60),    # ten hours
#        servers => ['127.0.0.1:11211'],
#        namespace => "validad_address_cat_sess_$user",
#    },
#
#    # authentication
#    authentication => {
#        default_realm => 'member',
#        realms        => {
#            member => {
#                credential => {
#                    class              => 'Password',
#                    password_field     => 'password',
#                    password_type      => 'hashed',
#                    password_hash_type => 'SHA-1',
#                },
#                store => {
#                    class      => 'DBIx::Class',
#                    user_class => 'DB::Usr',
#                    id_field   => 'id',
#                    use_userdata_from_session => 1,
#
#                    role_relation => 'usr_roles',
#                    role_field    => 'role',
#                },
#            },
#        },
#    },

#    'Plugin::PageCache' => {
#        expires => 300,
#        set_http_headers => 1,
#        debug => 0,
#    },
#    'Plugin::Cache' => {
#        backend => {
##           class   => "Cache::Memcached::Fast",
#            class   => "Cache::Memcached",
#            servers => ['127.0.0.1:11211'],
#            namespace => "validad_address_cat_sess_$user",
#        }
#    },
};