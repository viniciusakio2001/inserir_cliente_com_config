CREATE OR REPLACE FUNCTION inserir_cliente_com_config(
    p_nome TEXT,
    p_caminhoaplicacao TEXT,
    p_nomebase TEXT,
    p_nomeservidor TEXT,
    p_tipo TEXT, -- 'producao' ou 'homologacao'
    p_valor_item2 TEXT, -- valor para itemconfiguracaoid 2
    p_valor_item11 TEXT, -- só usado se tipo = 'homologacao'
    p_email_debug BOOLEAN DEFAULT TRUE
) RETURNS VOID AS $$
DECLARE
    v_cliente_id INTEGER;
BEGIN
    -- Inserir cliente
    INSERT INTO cliente (
        id,
        nome,
        caminhoaplicacao,
        nomebase,
        nomeservidor,
        ativo,
        emailservice_debug,
        sistema
    ) VALUES (
        nextval('cliente_seq'),
        p_nome,
        p_caminhoaplicacao,
        p_nomebase,
        p_nomeservidor,
        1,
        p_email_debug,
        'EFFORT'
    ) RETURNING id INTO v_cliente_id;

    -- Produção: apenas 1 configuração
    IF LOWER(p_tipo) = 'producao' THEN
        INSERT INTO clienteconfiguracao (
            id,
            clienteid,
            itemconfiguracaoid,
            usarvalorpadrao,
            valor
        ) VALUES (
            nextval('clienteconfiguracao_seq'),
            v_cliente_id,
            2,
            0,
            p_valor_item2
        );

    -- Homologação: 7 configurações
    ELSIF LOWER(p_tipo) = 'homologacao' THEN
        INSERT INTO clienteconfiguracao VALUES (
            nextval('clienteconfiguracao_seq'),
            v_cliente_id,
            31,
            0,
            'E:\UploadArquivoTemp\' || p_nomebase || '\Wallpaper\'
        );
        INSERT INTO clienteconfiguracao VALUES (
            nextval('clienteconfiguracao_seq'),
            v_cliente_id,
            29,
            0,
            'E:\UploadArquivoTemp\' || p_nomebase || '\'
        );
        INSERT INTO clienteconfiguracao VALUES (
            nextval('clienteconfiguracao_seq'),
            v_cliente_id,
            28,
            0,
            'E:\UploadArquivoTemp\' || p_nomebase || '\fotos\'
        );
        INSERT INTO clienteconfiguracao VALUES (
            nextval('clienteconfiguracao_seq'),
            v_cliente_id,
            11,
            0,
            p_valor_item11
        );
        INSERT INTO clienteconfiguracao VALUES (
            nextval('clienteconfiguracao_seq'),
            v_cliente_id,
            7,
            0,
            'https://' || p_nomeservidor || '/UploadArquivoTemp/' || p_nomebase || '/'
        );
        INSERT INTO clienteconfiguracao VALUES (
            nextval('clienteconfiguracao_seq'),
            v_cliente_id,
            6,
            0,
            'https://' || p_nomeservidor || '/UploadArquivoTemp/' || p_nomebase || '/fotos/'
        );
        INSERT INTO clienteconfiguracao VALUES (
            nextval('clienteconfiguracao_seq'),
            v_cliente_id,
            2,
            0,
            p_valor_item2
        );
    ELSE
        RAISE EXCEPTION 'Tipo inválido. Use "producao" ou "homologacao".';
    END IF;
END;
$$ LANGUAGE plpgsql;