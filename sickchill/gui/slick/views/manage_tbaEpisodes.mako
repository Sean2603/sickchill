<%inherit file="/layouts/main.mako" />
<%!
    import datetime
    import os

    from sickchill.helper import episode_num
%>

<%block name="content">
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
            <p>
                ${_('Episodes still titled TBA (airing up to 7 days ahead) can be refreshed from the indexer. Files that were post-processed while an episode was TBA keep that name until they are renamed.')}
                ${_('After a TBA update finishes, reload this page and the show moves to "files to rename".')}
            </p>
        </div>
    </div>

    % if not shows:
        <div class="row">
            <div class="col-md-12">
                <h3>${_('No TBA episode titles or TBA-named files found.')}</h3>
            </div>
        </div>
    % else:
        <%
            tba_shows = [item['show'].indexerid for item in shows if item['tba']]
            rename_shows = [item['show'].indexerid for item in shows if item['rename']]
        %>
        <div class="row">
            <div class="col-md-12">
                % if tba_shows:
                    <form method="post" action="${scRoot}/manage/tbaUpdate" class="form-inline" style="display: inline-block;">
                        % for show_id in tba_shows:
                            <input type="hidden" name="show" value="${show_id}" />
                        % endfor
                        <input type="submit" class="btn" value="${_('Update all TBA names')} (${len(tba_shows)})" />
                    </form>
                % endif
                % if rename_shows:
                    <form method="post" action="${scRoot}/manage/massRenamePreview" class="form-inline" style="display: inline-block;">
                        <input type="hidden" name="next" value="tba" />
                        % for show_id in rename_shows:
                            <input type="hidden" name="show" value="${show_id}" />
                        % endfor
                        <input type="submit" class="btn" value="${_('Preview rename for all')} (${len(rename_shows)})" />
                    </form>
                % endif
                <a href="${scRoot}/manage/tbaEpisodes/" class="btn">${_('Reload')}</a>
            </div>
        </div>
        <br/>
        <div class="row">
            <div class="col-md-12">
                <div class="horizontal-scroll">
                    <table class="sickchillTable">
                        <thead>
                            <tr>
                                <th class="nowrap">${_('Show')}</th>
                                <th>${_('TBA titles')}</th>
                                <th>${_('Files to rename')}</th>
                                <th class="nowrap">${_('Status')}</th>
                                <th class="nowrap">${_('Actions')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            % for item in shows:
                                <% show = item['show'] %>
                                <tr>
                                    <td class="nowrap"><a href="${scRoot}/home/displayShow?show=${show.indexerid}">${show.name}</a></td>
                                    <td>
                                        % if item['tba']:
                                            <details>
                                                <summary style="cursor: pointer;">&#9656; ${len(item['tba'])}</summary>
                                                <ul>
                                                    % for ep in item['tba']:
                                                        <li>
                                                            ${episode_num(ep['season'], ep['episode'])}
                                                            &mdash; ${datetime.date.fromordinal(ep['airdate'])}
                                                            % if ep['location']:
                                                                &mdash; ${_('downloaded')}
                                                            % endif
                                                        </li>
                                                    % endfor
                                                </ul>
                                            </details>
                                        % else:
                                            0
                                        % endif
                                    </td>
                                    <td>
                                        % if item['rename']:
                                            <details>
                                                <summary style="cursor: pointer;">&#9656; ${len(item['rename'])}</summary>
                                                <ul>
                                                    % for ep in item['rename']:
                                                        <li>${episode_num(ep['season'], ep['episode'])} &mdash; ${os.path.basename(ep['location'])}</li>
                                                    % endfor
                                                </ul>
                                            </details>
                                        % else:
                                            0
                                        % endif
                                    </td>
                                    <td class="nowrap">${item['state']}</td>
                                    <td class="nowrap">
                                        % if item['tba']:
                                            <a href="${scRoot}/manage/tbaUpdate?show=${show.indexerid}" class="btn btn-xs">${_('Update TBA names')}</a>
                                        % endif
                                        <a href="${scRoot}/manage/massRenamePreview?show=${show.indexerid}&amp;next=tba" class="btn btn-xs">${_('Preview rename')}</a>
                                    </td>
                                </tr>
                            % endfor
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    % endif

    <div class="row">
        <div class="col-md-12">
            <h2>${_('Unknown quality')}</h2>
            <p>
                ${_('Downloaded episodes stored with quality Unknown get "Unknown" in renamed file names. Fix quality re-checks the file name, then the video resolution (SD / 720p / 1080p / 4K), and saves what it finds. Rename afterwards to update the file names.')}
            </p>
        </div>
    </div>
    % if quality_fix_running:
        <div class="row">
            <div class="col-md-12">
                <p><strong>${_('A quality fix is running. Reload this page when it finishes.')}</strong></p>
            </div>
        </div>
    % endif
    % if not unknown_quality:
        <div class="row">
            <div class="col-md-12">
                <h3>${_('No downloaded episodes with unknown quality.')}</h3>
            </div>
        </div>
    % else:
        <div class="row">
            <div class="col-md-12">
                <form method="post" action="${scRoot}/manage/qualityFix" class="form-inline" style="display: inline-block;">
                    % for item in unknown_quality:
                        <input type="hidden" name="show" value="${item['show'].indexerid}" />
                    % endfor
                    <input type="submit" class="btn" value="${_('Fix quality for all')} (${len(unknown_quality)})" ${('', 'disabled')[quality_fix_running]} />
                </form>
                <form method="post" action="${scRoot}/manage/massRenamePreview" class="form-inline" style="display: inline-block;">
                    <input type="hidden" name="next" value="tba" />
                    % for item in unknown_quality:
                        <input type="hidden" name="show" value="${item['show'].indexerid}" />
                    % endfor
                    <input type="submit" class="btn" value="${_('Preview rename for all')} (${len(unknown_quality)})" />
                </form>
            </div>
        </div>
        <br/>
        <div class="row">
            <div class="col-md-12">
                <div class="horizontal-scroll">
                    <table class="sickchillTable">
                        <thead>
                            <tr>
                                <th class="nowrap">${_('Show')}</th>
                                <th>${_('Episodes with unknown quality')}</th>
                                <th class="nowrap">${_('Actions')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            % for item in unknown_quality:
                                <% show = item['show'] %>
                                <tr>
                                    <td class="nowrap"><a href="${scRoot}/home/displayShow?show=${show.indexerid}">${show.name}</a></td>
                                    <td>
                                        <details>
                                            <summary style="cursor: pointer;">&#9656; ${len(item['rows'])}</summary>
                                            <ul>
                                                % for ep in item['rows']:
                                                    <li>${episode_num(ep['season'], ep['episode'])} &mdash; ${os.path.basename(ep['location'])}</li>
                                                % endfor
                                            </ul>
                                        </details>
                                    </td>
                                    <td class="nowrap">
                                        <a href="${scRoot}/manage/qualityFix?show=${show.indexerid}" class="btn btn-xs" ${('', 'disabled')[quality_fix_running]}>${_('Fix quality')}</a>
                                        <a href="${scRoot}/manage/massRenamePreview?show=${show.indexerid}&amp;next=tba" class="btn btn-xs">${_('Preview rename')}</a>
                                    </td>
                                </tr>
                            % endfor
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    % endif
</%block>
