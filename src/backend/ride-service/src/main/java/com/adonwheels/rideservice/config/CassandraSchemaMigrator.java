package com.adonwheels.rideservice.config;

import com.datastax.oss.driver.api.core.CqlSession;
import com.datastax.oss.driver.api.core.servererrors.InvalidQueryException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Spring Data Cassandra runs with {@code SchemaAction.CREATE_IF_NOT_EXISTS},
 * which never alters an existing table. When a new column is added to an
 * entity, deployments with a pre-existing keyspace silently miss it and writes
 * fail with "Undefined column name". This component patches the schema at
 * startup by issuing idempotent {@code ALTER TABLE ... ADD} statements.
 */
@Component
public class CassandraSchemaMigrator {

    private static final Logger logger = LoggerFactory.getLogger(CassandraSchemaMigrator.class);

    private final CqlSession session;
    private final String keyspaceName;

    private record ColumnAddition(String table, String column, String cqlType) {}

    private static final List<ColumnAddition> ADDITIONS = List.of(
            new ColumnAddition("ride_sessions", "rate_per_km", "double")
    );

    public CassandraSchemaMigrator(CqlSession session,
                                   @Value("${cassandra.keyspace:ride_service}") String keyspaceName) {
        this.session = session;
        this.keyspaceName = keyspaceName;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void migrate() {
        for (ColumnAddition addition : ADDITIONS) {
            addColumnIfMissing(addition);
        }
    }

    private void addColumnIfMissing(ColumnAddition addition) {
        if (columnExists(addition.table(), addition.column())) {
            return;
        }
        String cql = String.format("ALTER TABLE %s.%s ADD %s %s",
                keyspaceName, addition.table(), addition.column(), addition.cqlType());
        try {
            session.execute(cql);
            logger.info("Cassandra migration: added column {}.{} ({})",
                    addition.table(), addition.column(), addition.cqlType());
        } catch (InvalidQueryException e) {
            logger.debug("Cassandra migration skipped for {}.{} - {}",
                    addition.table(), addition.column(), e.getMessage());
        }
    }

    private boolean columnExists(String table, String column) {
        var rs = session.execute(
                "SELECT column_name FROM system_schema.columns "
                        + "WHERE keyspace_name = ? AND table_name = ? AND column_name = ?",
                keyspaceName, table, column);
        return rs.one() != null;
    }
}
