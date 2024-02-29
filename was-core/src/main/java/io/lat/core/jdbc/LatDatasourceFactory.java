/*
 * Copyright 2022 LA:T Development Team.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package io.lat.core.jdbc;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.util.Hashtable;
import java.util.Properties;

import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.naming.Context;
import javax.naming.Name;
import javax.naming.RefAddr;
import javax.naming.Reference;

import org.apache.juli.logging.Log;
import org.apache.juli.logging.LogFactory;
import org.apache.tomcat.jdbc.pool.DataSource;
import org.apache.tomcat.jdbc.pool.DataSourceFactory;
import org.apache.tomcat.jdbc.pool.PoolConfiguration;
import org.apache.tomcat.jdbc.pool.XADataSource;

import io.lat.core.util.Encryptor;

/**
 * encrypt datasource password
 *
 * @author Erick Yu
 */
public class LatDatasourceFactory extends DataSourceFactory {

    private static final Log log = LogFactory.getLog(LatDatasourceFactory.class);

    public static final String PROP_PASSWORD_ENCRYPTED = "passwordEncrypted";
    protected static final String[] ALL_LAT_PROPERTIES = {
            PROP_PASSWORD_ENCRYPTED
    };
    private Encryptor encryptor = null;

    public LatDatasourceFactory() {
        try {
            encryptor = new Encryptor();
        } catch (Exception e) {
            // Do Nothing
        }
    }

    @Override
    public Object getObjectInstance(Object obj, Name name, Context nameCtx,
                                    Hashtable<?,?> environment) throws Exception {

        // We only know how to deal with <code>javax.naming.Reference</code>s
        // that specify a class name of "javax.sql.DataSource"
        if ((obj == null) || !(obj instanceof Reference)) {
            return null;
        }
        Reference ref = (Reference) obj;
        boolean XA = false;
        boolean ok = false;
        if ("javax.sql.DataSource".equals(ref.getClassName())) {
            ok = true;
        }
        if ("javax.sql.XADataSource".equals(ref.getClassName())) {
            ok = true;
            XA = true;
        }
        if (org.apache.tomcat.jdbc.pool.DataSource.class.getName().equals(ref.getClassName())) {
            ok = true;
        }

        if (!ok) {
            log.warn(ref.getClassName()+" is not a valid class name/type for this JNDI factory.");
            return null;
        }

        Properties properties = new Properties();
        for (int i = 0; i < ALL_PROPERTIES.length; i++) {
            String propertyName = ALL_PROPERTIES[i];
            RefAddr ra = ref.get(propertyName);
            if (ra != null) {
                String propertyValue = ra.getContent().toString();
                properties.setProperty(propertyName, propertyValue);
            }
        }

        /* changed code */
        for (int i = 0; i < ALL_LAT_PROPERTIES.length; i++) {
            String propertyName = ALL_LAT_PROPERTIES[i];
            RefAddr ra = ref.get(propertyName);
            if (ra != null) {
                String propertyValue = ra.getContent().toString();
                properties.setProperty(propertyName, propertyValue);
            }
        }
        /* changed code */

        return createDataSource(properties,nameCtx,XA);
    }

    @Override
    public DataSource createDataSource(Properties properties, Context context, boolean XA)
            throws InvalidKeyException, IllegalBlockSizeException, BadPaddingException, SQLException, NoSuchAlgorithmException, NoSuchPaddingException {
        // Here we decrypt our password.
        PoolConfiguration poolProperties = LatDatasourceFactory.parsePoolProperties(properties);
        if (isPasswordEncrypted(properties)) {
            poolProperties.setPassword(encryptor.decrypt(poolProperties.getPassword()));
        }

        // The rest of the code is copied from Tomcat's DataSourceFactory.
        if (poolProperties.getDataSourceJNDI() != null && poolProperties.getDataSource() == null) {
            performJNDILookup(context, poolProperties);
        }
        org.apache.tomcat.jdbc.pool.DataSource dataSource = XA ? new XADataSource(poolProperties) : new org.apache.tomcat.jdbc.pool.DataSource(poolProperties);
        dataSource.createPool();

        return dataSource;
    }

    public boolean isPasswordEncrypted(Properties properties) {
        return Boolean.parseBoolean(properties.getProperty(PROP_PASSWORD_ENCRYPTED, "false"));
    }

}
