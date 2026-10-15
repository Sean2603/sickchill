<%inherit file="/layouts/main.mako" />
<%!
    from sickchill import settings
%>
<%block name="scripts">
    <script type="text/javascript" src="${static_url('js/massRenamePreview.js')}"></script>
</%block>

<%block name="content">
    <form name="massRenameForm" method="post" action="${scRoot}/manage/massRenameSubmit">
        % if return_page == '/manage/tbaEpisodes/':
            <input type="hidden" name="next" value="tba" />
        % endif
        <div class="row">
            <div class="col-md-12">
                % if not header is UNDEFINED:
                    <h1 class="header">${header}</h1>
                % else:
                    <h1 class="title">${title}</h1>
                % endif
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <h3>${_('Preview of the proposed name changes')}</h3>
                <blockquote>${settings.NAMING_PATTERN}</blockquote>
                <p>
                    ${_('{count} of {selected} selected show(s) have files to rename.').format(count=len(shows), selected=selected)}
                    % if skipped:
                        <br/>${_('Skipped (show folder missing)')}: ${', '.join(skipped)}
                    % endif
                </p>
            </div>
        </div>

        % if shows:
            <div class="row">
                <div class="col-md-12">
                    <input type="checkbox" id="massRenameAll" />
                    <label for="massRenameAll">${_('select all')}</label>
                    &nbsp;&nbsp;
                    <input type="checkbox" id="massRenameTbaOnly" />
                    <label for="massRenameTbaOnly">${_('only show files currently named TBA')}</label>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <input type="submit" value="${_('Rename Selected')}" class="btn btn-success massRenameSubmit" />
                    <a href="${scRoot}${return_page}" class="btn btn-danger">${_('Cancel Rename')}</a>
                </div>
            </div>

            % for item in shows:
                <% show = item['show'] %>
                <div class="row massRenameShow">
                    <div class="col-md-12">
                        <h2>
                            <input type="checkbox" class="massRenameShowCheck" data-show="${show.indexerid}" title="${_('Select all episodes of')} ${show.name}" />
                            <a href="${scRoot}/home/displayShow?show=${show.indexerid}">${show.name}</a>
                            <small>(${len(item['rows'])})</small>
                        </h2>
                        <div class="horizontal-scroll">
                            <table class="sickchillTable">
                                <thead>
                                    <tr>
                                        <th class="col-checkbox"></th>
                                        <th class="nowrap">${_('Episode')}</th>
                                        <th class="col-name">${_('Old Location')}</th>
                                        <th class="col-name">${_('New Location')}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    % for row in item['rows']:
                                        <tr class="wanted seasonstyle massRenameRow" data-tba="${('0', '1')['TBA' in row['old']]}">
                                            <td class="col-checkbox">
                                                <input type="checkbox" class="massRenameEp show-${show.indexerid}" name="ep" value="${row['id']}" title="${_('Episode check')}" />
                                            </td>
                                            <td align="center" valign="top" class="nowrap">${row['season']}x${row['episode']}</td>
                                            <td width="50%" class="col-name">${row['old']}</td>
                                            <td width="50%" class="col-name">${row['new']}</td>
                                        </tr>
                                    % endfor
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            % endfor

            <br/>
            <div class="row">
                <div class="col-md-12">
                    <input type="submit" value="${_('Rename Selected')}" class="btn btn-success massRenameSubmit" />
                    <a href="${scRoot}${return_page}" class="btn btn-danger">${_('Cancel Rename')}</a>
                </div>
            </div>
        % else:
            <div class="row">
                <div class="col-md-12">
                    <a href="${scRoot}${return_page}" class="btn">${_('Back')}</a>
                </div>
            </div>
        % endif
    </form>
</%block>
